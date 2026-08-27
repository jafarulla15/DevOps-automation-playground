resource "docker_volume" "grafana_data" {
  name = var.data_volume
}

resource "docker_container" "grafana" {
  name  = var.container_name
  image = var.image

  restart = "unless-stopped"

  ports {
    internal = 3000
    external = var.port
  }

  env = [
    "GF_SECURITY_ADMIN_USER=${var.admin_user}",
    "GF_SECURITY_ADMIN_PASSWORD=${var.admin_password}",
    "GF_USERS_ALLOW_SIGN_UP=false"
  ]

  volumes {
    volume_name    = docker_volume.grafana_data.name
    container_path = "/var/lib/grafana"
  }

  networks_advanced {
    name = var.network_name
  }

  depends_on = [
    docker_volume.grafana_data
  ]
}
