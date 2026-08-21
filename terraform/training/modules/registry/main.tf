resource "docker_volume" "data" {
  name = "registry_data"
}

resource "docker_container" "this" {
  name    = "registry"
  image   = var.image
  restart = "unless-stopped"

  ports {
    internal = 5000
    external = var.port
  }

  volumes {
    volume_name    = docker_volume.data.name
    container_path = "/var/lib/registry"
  }

  networks_advanced {
    name = var.network_name
  }
}
