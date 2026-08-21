resource "docker_volume" "data" {
  name = "vault_data"
}

resource "docker_container" "this" {
  name    = "vault"
  image   = var.image
  restart = "unless-stopped"

  cap_add = ["IPC_LOCK"]

  ports {
    internal = 8200
    external = var.port
  }

  env = [
    "VAULT_DEV_ROOT_TOKEN_ID=dev-root-token",
    "VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200"
  ]

  command = ["server", "-dev"]

  volumes {
    volume_name    = docker_volume.data.name
    container_path = "/vault/file"
  }

  networks_advanced {
    name = var.network_name
  }
}
