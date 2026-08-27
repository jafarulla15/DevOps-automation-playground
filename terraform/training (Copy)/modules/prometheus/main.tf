resource "docker_volume" "prometheus_data" {
  name = var.data_volume
}

resource "docker_container" "prometheus" {
  name  = var.container_name
  image = var.image

  restart = "unless-stopped"

  ports {
    internal = 9090
    external = var.port
  }

  volumes {
    host_path      = abspath(var.config_file)
    container_path = "/etc/prometheus/prometheus.yml"
    read_only      = true
  }

  volumes {
    volume_name    = docker_volume.prometheus_data.name
    container_path = "/prometheus"
  }

  command = [
    "--config.file=/etc/prometheus/prometheus.yml",
    "--storage.tsdb.path=/prometheus",
    "--storage.tsdb.retention.time=15d"
  ]

  networks_advanced {
    name = var.network_name
  }
}
