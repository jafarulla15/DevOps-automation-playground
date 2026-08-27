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

# Others

output "loki_url" {
  value = module.loki.url
}

output "otel_grpc_endpoint" {
  value = module.opentelemetry.grpc_endpoint
}

output "otel_http_endpoint" {
  value = module.opentelemetry.http_endpoint
}

output "redis_endpoint" {
  value = module.redis.endpoint
}

output "rabbitmq_amqp_endpoint" {
  value = module.rabbitmq.amqp_endpoint
}

output "rabbitmq_management_url" {
  value = module.rabbitmq.management_url
}

output "alertmanager_url" {
  value = module.alertmanager.url
}

output "vault_url" {
  value = module.vault.url
}

output "registry_url" {
  value = module.registry.url
}

# Application pipelines

output "application_urls" {
  description = "URL for each Jenkins-deployed application, keyed by pipeline name"
  value = {
    for key, port in module.app_pipelines.host_ports :
    key => port != null ? "http://${var.server_ip}:${port}" : "not published on a host port - reachable via the monitoring network only"
  }
}

output "application_jenkins_jobs" {
  description = "Jenkins job name for each application pipeline"
  value       = module.app_pipelines.job_names
}



