module "docker" {
  source = "./modules/docker"

  server_ip            = var.server_ip
  ssh_user             = var.ssh_user
  ssh_private_key_path = var.ssh_private_key_path
}

module "sqlserver" {
  source = "./modules/sqlserver"

  container_name = "sqlserver-express"

  image = "mcr.microsoft.com/mssql/server:2022-latest"

  host_port      = 1433
  container_port = 1433

  sa_password = var.sqlserver_sa_password

  edition = "Express"

  volume_name = "sqlserver_data"

  restart_policy = "unless-stopped"

  depends_on = [module.docker]
}

module "jenkins" {
  source = "./modules/jenkins"

  container_name = "jenkins"

  image = "earn-jenkins:lts"

  host_port = 8080

  agent_host_port = 50000

  volume_name = "jenkins_home"

  timezone = "Asia/Dhaka"

  admin_user = "admin"

  admin_password = var.jenkins_admin_password

  jenkins_host = var.server_ip

  depends_on = [module.docker]
}

resource "docker_network" "monitoring" {
  name = "monitoring"
}

#resource "docker_network" "monitoring" {
#  name = var.network_name
#}

module "prometheus" {
  source = "./modules/prometheus"

  container_name = "prometheus"
  port           = 9090
  network_name   = docker_network.monitoring.name

  config_file = "${path.root}/prometheus/prometheus.yml"
  data_volume = "prometheus_data"

  depends_on = [module.docker]
}

module "grafana" {
  source = "./modules/grafana"

  container_name = "grafana"
  port           = 3000
  network_name   = docker_network.monitoring.name

  data_volume = "grafana_data"

  admin_user     = var.grafana_admin_user
  admin_password = var.grafana_admin_password

  depends_on = [module.docker]
}



# others

module "loki" {
  source       = "./modules/loki"
  network_name = docker_network.monitoring.name
  port         = var.loki_port
  config_file  = "${path.root}/configs/loki/loki-config.yml"

  depends_on = [module.docker]
}

module "opentelemetry" {
  source       = "./modules/opentelemetry"
  network_name = docker_network.monitoring.name
  grpc_port    = var.otel_grpc_port
  http_port    = var.otel_http_port
  config_file  = "${path.root}/configs/otel/otel-collector-config.yml"

  depends_on = [module.docker]
}

module "redis" {
  source       = "./modules/redis"
  network_name = docker_network.monitoring.name
  port         = var.redis_port

  depends_on = [module.docker]
}

module "rabbitmq" {
  source          = "./modules/rabbitmq"
  network_name    = docker_network.monitoring.name
  amqp_port       = var.rabbitmq_port
  management_port = var.rabbitmq_management_port

  depends_on = [module.docker]
}

module "alertmanager" {
  source       = "./modules/alertmanager"
  network_name = docker_network.monitoring.name
  port         = var.alertmanager_port
  config_file  = "${path.root}/configs/alertmanager/alertmanager.yml"

  depends_on = [module.docker]
}

module "vault" {
  source       = "./modules/vault"
  network_name = docker_network.monitoring.name
  port         = var.vault_port

  depends_on = [module.docker]
}

module "registry" {
  source       = "./modules/registry"
  network_name = docker_network.monitoring.name
  port         = var.registry_port

  depends_on = [module.docker]
}

module "app_pipelines" {
  source = "./modules/jenkins-pipeline"

  pipelines = {
    dotnet-api = {
      application_name      = "earn-dotnet-api"
      git_repository_url    = "https://github.com/jafarulla15/DevOps-Demo-REST-Api.git"
      git_branch            = "main"
      git_credentials_id    = "github-jenkins-pat"
      docker_registry       = "192.168.238.50:5000"
      container_name        = "demo-dotnet-api"
      container_port        = 8070
      host_port             = 5000
      docker_network        = docker_network.monitoring.name
      poll_schedule         = "H/10 * * * *"
      deploy_trigger_phrase = "deploy it now"
    }

    dotnet-api2 = {
      application_name      = "earn-dotnet-api2"
      git_repository_url    = "https://github.com/jafarulla15/DevOps-Demo-REST-Api.git"
      git_branch            = "main"
      git_credentials_id    = "github-jenkins-pat"
      docker_registry       = "192.168.238.50:5000"
      container_name        = "demo-dotnet-api2"
      container_port        = 8070
      host_port             = 5001
      docker_network        = docker_network.monitoring.name
      poll_schedule         = "H/10 * * * *"
      deploy_trigger_phrase = "deploy it now"
    }

    angular-app = {
      application_name      = "earn-angular-app"
      git_repository_url    = "https://github.com/jafarulla15/DevOps-Demo-Angular.git"
      git_branch            = "main"
      git_credentials_id    = "github-jenkins-pat"
      docker_registry       = "192.168.238.50:5000"
      container_name        = "demo-angular-app"
      container_port        = 80
      host_port             = 4600
      docker_network        = docker_network.monitoring.name
      poll_schedule         = "H/10 * * * *"
      deploy_trigger_phrase = "deploy it now"
    }
  }

  depends_on = [module.jenkins]
}
