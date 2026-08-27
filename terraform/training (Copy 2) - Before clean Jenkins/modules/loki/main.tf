resource "docker_volume" "data" {
  name = "loki_data"
}

resource "docker_container" "this" {
  name    = "loki"
  image   = var.image
  restart = "unless-stopped"

  ports {
    internal = 3100
    external = var.port
  }

  volumes {
    host_path      = abspath(var.config_file)
    container_path = "/etc/loki/config.yml"
    read_only      = true
  }

  volumes {
    volume_name    = docker_volume.data.name
    container_path = "/loki"
  }

  command = ["-config.file=/etc/loki/config.yml"]

  networks_advanced {
    name = var.network_name
  }
}
