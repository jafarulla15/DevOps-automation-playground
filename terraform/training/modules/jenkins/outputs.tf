output "container_name" {
  description = "Jenkins container name"
  value       = docker_container.jenkins.name
}

output "container_id" {
  description = "Jenkins container ID"
  value       = docker_container.jenkins.id
}

output "host_port" {
  description = "Jenkins web UI port"
  value       = var.host_port
}

output "agent_port" {
  description = "Jenkins agent port"
  value       = var.agent_host_port
}

output "volume_name" {
  description = "Jenkins persistent volume"
  value       = docker_volume.jenkins_home.name
}

output "url" {
  description = "Jenkins URL"
  value       = "http://${var.jenkins_host}:${var.host_port}"
}

output "admin_user" {
  description = "Jenkins administrator username"
  value       = var.admin_user
}
