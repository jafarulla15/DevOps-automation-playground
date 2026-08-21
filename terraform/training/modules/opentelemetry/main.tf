resource "docker_container" "this" {
  name    = "otel-collector"
  image   = var.image
  restart = "unless-stopped"

  ports {
    internal = 4317
    external = var.grpc_port
  }

  ports {
    internal = 4318
    external = var.http_port
  }

  volumes {
    host_path      = abspath(var.config_file)
    container_path = "/etc/otelcol/config.yaml"
    read_only      = true
  }

  command = ["--config=/etc/otelcol/config.yaml"]

  networks_advanced {
    name = var.network_name
  }
}
