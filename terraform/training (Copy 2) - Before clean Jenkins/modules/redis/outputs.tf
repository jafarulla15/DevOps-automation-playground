output "container_name" {
  description = "Docker container name"
  value       = docker_container.this.name
}

output "endpoint" {
  description = "HashiCorp Vault endpoint"
  value       = "localhost:${var.port}"
}
