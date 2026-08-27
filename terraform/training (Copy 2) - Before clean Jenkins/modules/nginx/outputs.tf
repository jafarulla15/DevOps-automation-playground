output "container_name" {
  description = "Nginx container name"
  value       = docker_container.nginx.name
}

output "http_port" {
  description = "Nginx HTTP host port"
  value       = var.http_port
}

output "https_port" {
  description = "Nginx HTTPS host port"
  value       = var.https_port
}

output "server_names" {
  description = "Configured server_name per application, keyed like var.applications"
  value       = { for k, a in var.applications : k => a.server_name }
}
