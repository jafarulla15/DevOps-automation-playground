output "server_ip" {
  value = var.server_ip
}

output "server_name" {
  value = var.server_name
}

output "docker_server_ip" {
  description = "IP address of the server where Docker was installed"
  value       = module.docker.server_ip
}

output "docker_installation_status" {
  description = "Docker installation status"
  value       = module.docker.installation_status
}
