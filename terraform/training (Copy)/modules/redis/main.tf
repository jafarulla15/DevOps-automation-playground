resource "docker_volume" "data" {
  name = "redis_data"
}

resource "docker_container" "this" {
  name    = "redis"
  image   = var.image
  restart = "unless-stopped"

  ports {
    internal = 6379
    external = var.port
  }

  volumes {
    volume_name    = docker_volume.data.name
    container_path = "/data"
  }

  command = ["redis-server", "--appendonly", "yes"]

  networks_advanced {
    name = var.network_name
  }
}
