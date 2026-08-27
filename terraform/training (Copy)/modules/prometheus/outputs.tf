output "container_name" {
  description = "Prometheus container name"
  value       = docker_container.prometheus.name
}

output "container_id" {
  description = "Prometheus container ID"
  value       = docker_container.prometheus.id
}

output "port" {
  description = "Prometheus host port"
  value       = var.port
}

output "url" {
  description = "Prometheus URL"
  value       = "http://localhost:${var.port}"
}

output "volume_name" {
  description = "Prometheus data volume"
  value       = docker_volume.prometheus_data.name
}
