output "container_name" {
  description = "Docker container name"
  value       = docker_container.this.name
}

output "url" {
  description = "HashiCorp Vault URL"
  value       = "http://localhost:${var.port}"
}

output "dev_root_token" {
  description = "HashiCorp Vault development root token"
  value       = "dev-root-token"
  sensitive   = true
}
