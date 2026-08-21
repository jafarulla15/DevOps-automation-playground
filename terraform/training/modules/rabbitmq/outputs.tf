output "container_name" {
  description = "Docker container name"
  value       = docker_container.this.name
}

output "amqp_endpoint" {
  description = "RabbitMQ AMQP endpoint"
  value       = "amqp://localhost:${var.amqp_port}"
}

output "management_url" {
  description = "RabbitMQ management URL"
  value       = "http://localhost:${var.management_port}"
}
