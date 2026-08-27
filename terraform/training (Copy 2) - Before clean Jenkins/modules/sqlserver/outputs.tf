output "container_name" {
  description = "SQL Server container name"
  value       = docker_container.sqlserver.name
}

output "container_id" {
  description = "SQL Server Docker container ID"
  value       = docker_container.sqlserver.id
}

output "host_port" {
  description = "SQL Server host port"
  value       = var.host_port
}

output "container_port" {
  description = "SQL Server container port"
  value       = var.container_port
}

output "volume_name" {
  description = "SQL Server persistent Docker volume"
  value       = docker_volume.sqlserver_data.name
}

output "connection_server" {
  description = "SQL Server hostname and port"
  value       = "localhost:${var.host_port}"
}
