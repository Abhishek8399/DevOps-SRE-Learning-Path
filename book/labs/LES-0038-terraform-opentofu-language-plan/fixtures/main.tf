terraform {
  required_version = ">= 1.6.0, < 2.0.0"
}

variable "environment" {
  description = "Short lowercase environment identity used only by this local plan."
  type        = string
  default     = "practice"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,15}$", var.environment))
    error_message = "environment must be 3-16 lowercase letters, digits, or hyphens and start with a letter."
  }
}

variable "services" {
  description = "Fictional services transformed into built-in terraform_data resources."
  type = map(object({
    port     = number
    replicas = number
    labels   = set(string)
  }))

  default = {
    api = {
      port     = 8080
      replicas = 2
      labels   = ["critical", "http"]
    }
    worker = {
      port     = 9090
      replicas = 1
      labels   = ["async"]
    }
  }

  validation {
    condition = alltrue([
      for service in values(var.services) :
      service.port >= 1024 && service.port <= 65535 && service.replicas >= 1 && service.replicas <= 10
    ])
    error_message = "every service needs an unprivileged port and 1-10 replicas."
  }
}

locals {
  normalized_services = {
    for name, service in var.services : name => {
      identity = "${var.environment}-${name}"
      port     = service.port
      replicas = service.replicas
      labels   = sort(tolist(service.labels))
    }
  }

  total_replicas = sum([for service in values(var.services) : service.replicas])
}

resource "terraform_data" "service" {
  for_each = local.normalized_services

  input = each.value

  lifecycle {
    precondition {
      condition     = length(each.value.labels) > 0
      error_message = "every service needs at least one operational label."
    }
  }
}

resource "terraform_data" "catalog" {
  input = {
    environment    = var.environment
    service_names  = sort(keys(terraform_data.service))
    total_replicas = local.total_replicas
  }
}

output "service_summary" {
  description = "Stable, non-sensitive summary used by tests and plan review."
  value = {
    environment    = terraform_data.catalog.output.environment
    service_names  = terraform_data.catalog.output.service_names
    total_replicas = terraform_data.catalog.output.total_replicas
    ports = {
      for name, resource in terraform_data.service : name => resource.output.port
    }
  }
}
