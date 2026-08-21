resource "docker_volume" "data" {
  name = "rabbitmq_data"
}

resource "docker_container" "this" {
  name    = "rabbitmq"
  image   = var.image
  restart = "unless-stopped"

  ports {
    internal = 5672
    external = var.amqp_port
  }

  ports {
    internal = 15672
    external = var.management_port
  }

  env = [
    "RABBITMQ_DEFAULT_USER=${var.username}",
    "RABBITMQ_DEFAULT_PASS=${var.password}"
  ]

  volumes {
    volume_name    = docker_volume.data.name
    container_path = "/var/lib/rabbitmq"
  }

  networks_advanced {
    name = var.network_name
  }
}
