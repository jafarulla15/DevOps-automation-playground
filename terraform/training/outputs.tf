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

# SQL - Server

output "sqlserver_container" {
  value = module.sqlserver.container_name
}

output "sqlserver_port" {
  value = module.sqlserver.host_port
}

output "sqlserver_volume" {
  value = module.sqlserver.volume_name
}

output "sqlserver_connection" {
  value = module.sqlserver.connection_server
}

# Jenkins

output "jenkins_container" {
  value = module.jenkins.container_name
}

output "jenkins_url" {
  value = module.jenkins.url
}

output "jenkins_volume" {
  value = module.jenkins.volume_name
}

output "jenkins_agent_port" {
  value = module.jenkins.agent_port
}

output "jenkins_admin_user" {
  value = module.jenkins.admin_user
}

# Prometheus

output "prometheus_url" {
  description = "Prometheus URL"
  value       = module.prometheus.url
}

output "prometheus_container" {
  description = "Prometheus container"
  value       = module.prometheus.container_name
}

# Grafana

output "grafana_url" {
  description = "Grafana URL"
  value       = module.grafana.url
}

output "grafana_container" {
  description = "Grafana container"
  value       = module.grafana.container_name
}
