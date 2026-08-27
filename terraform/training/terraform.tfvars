server_name          = "earn-training"
ssh_user             = "jafar"
server_ip            = "192.168.238.50"
ssh_private_key_path = "~/.ssh/id_ed25519"

# SQL - Server
sqlserver_sa_password = "YourStrongPassword123!"

# Jenkins 
jenkins_admin_password = "YourStrongPassword123!"

#Grafana
grafana_admin_user     = "admin"
grafana_admin_password = "YourStrongPassword123!"

# Redis
redis_password = "CHANGE_ME"

# RabbitMQ
rabbitmq_username = "earn"
rabbitmq_password = "CHANGE_ME"

# Vault
vault_root_token = "CHANGE_ME"

# Jenkins provider connection (jenkins_password is set via TF_VAR_jenkins_password instead)
jenkins_url      = "http://192.168.238.50:8080"
jenkins_username = "admin"
