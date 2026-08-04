environment = "review"

services = {
  api = {
    port     = 8080
    replicas = 3
    labels   = ["critical", "http"]
  }
  worker = {
    port     = 9090
    replicas = 2
    labels   = ["async", "batch"]
  }
}
