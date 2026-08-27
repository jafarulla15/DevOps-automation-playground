resource "docker_volume" "jenkins_home" {
  name = var.volume_name
}

resource "docker_image" "jenkins" {
  name = var.image

  build {
    context    = path.module
    dockerfile = "Dockerfile"
  }

  # Without this, Terraform has no way to notice that the Dockerfile or its
  # build context changed, since none of the arguments above change value -
  # it would silently keep the stale image forever.
  triggers = {
    dockerfile_sha1 = filesha1("${path.module}/Dockerfile")
    plugins_sha1    = filesha1("${path.module}/config/plugins.txt")
    jcasc_sha1      = filesha1("${path.module}/config/jenkins.yaml")
  }

  keep_locally = true
}

resource "docker_container" "jenkins" {

  name  = var.container_name
  image = docker_image.jenkins.image_id

  restart = var.restart_policy

  env = [
    "TZ=${var.timezone}",
    "JENKINS_ADMIN_USER=${var.admin_user}",
    "JENKINS_ADMIN_PASSWORD=${var.admin_password}",
    "JENKINS_HOST=${var.jenkins_host}",
    "JENKINS_PORT=${var.host_port}",
    "CASC_JENKINS_CONFIG=/usr/share/jenkins/ref/jenkins.yaml"
  ]

  ports {
    internal = var.container_port
    external = var.host_port
  }

  ports {
    internal = var.agent_container_port
    external = var.agent_host_port
  }

  volumes {
    volume_name    = docker_volume.jenkins_home.name
    container_path = "/var/jenkins_home"
  }

  # Allow Jenkins pipelines to communicate
  # with the Docker daemon on the host.
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  shm_size = 1073741824
}
