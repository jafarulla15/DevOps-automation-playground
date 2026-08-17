resource "null_resource" "docker_install" {

  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = var.ssh_user
    private_key = file(pathexpand(var.ssh_private_key_path))
  }

  provisioner "remote-exec" {
    inline = [

      "echo '============================================='",
      "echo ' DOCKER INSTALLATION STARTED'",
      "echo '============================================='",

      "echo 'STEP 1: Detect Ubuntu version'",
      "cat /etc/os-release",

      "echo 'STEP 2: Update package index'",
      "sudo -n apt-get update",

      "echo 'STEP 3: Install required packages'",
      "sudo -n DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl gnupg",

      "echo 'STEP 4: Create Docker keyring directory'",
      "sudo -n install -m 0755 -d /etc/apt/keyrings",

      "echo 'STEP 5: Download Docker GPG key'",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo -n gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg",

      "echo 'STEP 6: Set GPG key permissions'",
      "sudo -n chmod a+r /etc/apt/keyrings/docker.gpg",

      "echo 'STEP 7: Configure Docker repository'",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable\" | sudo -n tee /etc/apt/sources.list.d/docker.list > /dev/null",

      "echo 'STEP 8: Update package index with Docker repository'",
      "sudo -n apt-get update",

      "echo 'STEP 9: Install Docker Engine'",
      "sudo -n DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",

      "echo 'STEP 10: Enable Docker service'",
      "sudo -n systemctl enable docker",

      "echo 'STEP 11: Start Docker service'",
      "sudo -n systemctl start docker",

      "echo 'STEP 12: Add SSH user to Docker group'",
      "sudo -n usermod -aG docker $(whoami)",

      "echo 'STEP 13: Verify Docker service'",
      "sudo -n systemctl is-active docker",

      "echo 'STEP 14: Verify Docker version'",
      "sudo -n docker --version",

      "echo 'STEP 15: Verify Docker Compose'",
      "sudo -n docker compose version",

      "echo 'STEP 16: Run Docker test container'",
      "sudo -n docker run --rm hello-world",

      "echo '============================================='",
      "echo ' DOCKER INSTALLATION COMPLETED'",
      "echo '============================================='"
    ]
  }
}
