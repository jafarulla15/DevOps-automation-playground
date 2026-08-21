output "container_name" {
  description = "Docker container name"
  value       = docker_container.this.name
}

output "url" {
  description = "Service URL"
  value       = "http://localhost:${var.port}"
}
