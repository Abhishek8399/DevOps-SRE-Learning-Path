variable "components" {
  type = map(object({
    owner = string
    port  = number
  }))

  validation {
    condition = alltrue([
      for component in values(var.components) :
      component.port >= 1024 && component.port <= 65535 && component.owner != ""
    ])
    error_message = "Every component needs a nonempty owner and unprivileged valid port."
  }
}

resource "terraform_data" "component" {
  for_each = var.components

  input = {
    name  = each.key
    owner = each.value.owner
    port  = each.value.port
  }
}

output "component_ids" {
  value = {
    for name, component in terraform_data.component : name => component.id
  }
}
