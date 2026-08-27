resource "docker_volume" "data" {
  name = "alertmanager_data"
}

resource "docker_container" "this" {
  name    = "alertmanager"
  image   = var.image
  restart = "unless-stopped"

  ports {
    internal = 9093
    external = var.port
  }

  volumes {
    host_path      = abspath(var.config_file)
    container_path = "/etc/alertmanager/alertmanager.yml"
    read_only      = true
  }

  volumes {
    volume_name    = docker_volume.data.name
    container_path = "/alertmanager"
  }

  command = [
    "--config.file=/etc/alertmanager/alertmanager.yml",
    "--storage.path=/alertmanager"
  ]

  networks_advanced {
    name = var.network_name
  }
}
