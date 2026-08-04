terraform {
  required_version = ">= 1.9.0"
}

module "service" {
  source = "./modules/service"

  components = {
    api = {
      owner = "platform"
      port  = 8080
    }
    worker = {
      owner = "platform"
      port  = 9090
    }
  }
}

moved {
  from = terraform_data.api
  to   = module.service.terraform_data.component["api"]
}

moved {
  from = terraform_data.worker
  to   = module.service.terraform_data.component["worker"]
}

output "component_ids" {
  value = module.service.component_ids
}
