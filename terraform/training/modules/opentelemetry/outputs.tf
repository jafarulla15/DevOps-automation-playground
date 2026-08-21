output "container_name" {
  description = "Docker container name"
  value       = docker_container.this.name
}

output "grpc_endpoint" {
  description = "gRPC endpoint"
  value       = "http://localhost:${var.grpc_port}"
}

output "http_endpoint" {
  description = "HTTP endpoint"
  value       = "http://localhost:${var.http_port}"
}
