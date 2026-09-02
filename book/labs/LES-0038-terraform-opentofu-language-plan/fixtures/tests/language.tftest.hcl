run "default_plan" {
  command = plan

  assert {
    condition     = var.environment == "practice"
    error_message = "the default environment changed unexpectedly"
  }

  assert {
    condition     = toset(keys(terraform_data.service)) == toset(["api", "worker"])
    error_message = "the stable service identity set changed"
  }

  assert {
    condition     = local.total_replicas == 3
    error_message = "replica aggregation is incorrect"
  }
}

run "changed_input_plan" {
  command = plan

  variables {
    environment = "review"
    services = {
      gateway = {
        port     = 8443
        replicas = 3
        labels   = ["edge", "tls"]
      }
    }
  }

  assert {
    condition     = var.environment == "review"
    error_message = "explicit environment input was not propagated"
  }

  assert {
    condition     = toset(keys(terraform_data.service)) == toset(["gateway"])
    error_message = "for_each identity did not follow the supplied map key"
  }
}
