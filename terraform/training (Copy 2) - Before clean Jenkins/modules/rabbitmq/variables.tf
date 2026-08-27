variable "network_name" {
  description = "Docker network name"
  type        = string
  default     = "monitoring"
}

variable "amqp_port" {
  description = "RabbitMQ AMQP host port"
  type        = number
  default     = 5672
}

variable "management_port" {
  description = "RabbitMQ management UI host port"
  type        = number
  default     = 15672
}

variable "image" {
  description = "RabbitMQ Docker image"
  type        = string
  default     = "rabbitmq:4-management"
}

variable "username" {
  description = "RabbitMQ default username"
  type        = string
  default     = "admin"
}

variable "password" {
  description = "RabbitMQ default password"
  type        = string
  default     = "ChangeMe@123"
  sensitive   = true
}
