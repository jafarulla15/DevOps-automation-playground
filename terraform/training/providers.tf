terraform {
  required_version = ">= 1.9.0"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }

    jenkins = {
      source  = "taiidani/jenkins"
      version = "~> 0.10"
    }
  }
}

#provider "docker" {
#  host = "unix:///var/run/docker.sock"
#}

provider "jenkins" {
  server_url = var.jenkins_url
  username   = var.jenkins_username
  password   = var.jenkins_password
}
