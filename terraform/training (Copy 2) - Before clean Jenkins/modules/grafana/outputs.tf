output "container_name" {
  description = "Grafana container name"
  value       = docker_container.grafana.name
}

output "container_id" {
  description = "Grafana container ID"
  value       = docker_container.grafana.id
}

output "port" {
  description = "Grafana host port"
  value       = var.port
}

output "url" {
  description = "Grafana URL"
  value       = "http://localhost:${var.port}"
}

output "volume_name" {
  description = "Grafana data volume"
  value       = docker_volume.grafana_data.name
}
