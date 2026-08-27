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
  }
}

#provider "docker" {
#  host = "unix:///var/run/docker.sock"
#}
