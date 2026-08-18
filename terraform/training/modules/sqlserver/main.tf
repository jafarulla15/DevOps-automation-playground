resource "docker_volume" "sqlserver_data" {
  name = var.volume_name
}

resource "docker_container" "sqlserver" {

  name  = var.container_name
  image = docker_image.sqlserver.image_id

  restart = var.restart_policy

  env = [
    "ACCEPT_EULA=Y",
    "MSSQL_SA_PASSWORD=${var.sa_password}",
    "MSSQL_PID=${var.edition}"
  ]

  ports {
    internal = var.container_port
    external = var.host_port
  }

  volumes {
    volume_name    = docker_volume.sqlserver_data.name
    container_path = "/var/opt/mssql"
  }

  shm_size = 1073741824
}

resource "docker_image" "sqlserver" {
  name = var.image

  keep_locally = true
}
