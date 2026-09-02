terraform {
  required_version = ">= 1.9.0"
}

resource "terraform_data" "api" {
  input = {
    name  = "api"
    owner = "platform"
    port  = 8080
  }
}

resource "terraform_data" "worker" {
  input = {
    name  = "worker"
    owner = "platform"
    port  = 9090
  }
}

output "component_ids" {
  value = {
    api    = terraform_data.api.id
    worker = terraform_data.worker.id
  }
}
