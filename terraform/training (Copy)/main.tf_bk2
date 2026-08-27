resource "null_resource" "server_bootstrap" {

  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = var.ssh_user
    private_key = file(pathexpand(var.ssh_private_key_path))
  }

provisioner "remote-exec" {
  inline = [

    # Stop provisioning immediately if any command fails
    "set -e",

    "echo '========== STEP 1: SYSTEM UPDATE =========='",
    "sudo -n apt-get update",
    "sudo -n env DEBIAN_FRONTEND=noninteractive apt-get upgrade -y",

    "echo '========== STEP 2: BASIC TOOLS =========='",
    "sudo -n apt-get install -y ca-certificates curl wget git unzip jq vim htop net-tools ufw",

    "echo '========== STEP 3: DOCKER REPOSITORY =========='",
    "sudo -n install -m 0755 -d /etc/apt/keyrings",
    "sudo -n rm -f /etc/apt/sources.list.d/docker.list",
    "sudo -n rm -f /etc/apt/sources.list.d/docker.sources",
    "sudo -n curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc",
    "sudo -n chmod a+r /etc/apt/keyrings/docker.asc",

    "echo '========== STEP 4: DOCKER REPOSITORY CONFIG =========='",
    "ARCH=$(dpkg --print-architecture) && CODENAME=$(. /etc/os-release && echo $VERSION_CODENAME) && echo \"deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $CODENAME stable\" | sudo -n tee /etc/apt/sources.list.d/docker.list > /dev/null",

    "echo '========== STEP 5: DOCKER INSTALLATION =========='",
    "sudo -n apt-get update",
    "sudo -n env DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",

    "echo '========== STEP 6: DOCKER USER PERMISSION =========='",
    "sudo -n usermod -aG docker ${var.ssh_user}",

    "echo '========== STEP 7: DOCKER SERVICE =========='",
    "sudo -n systemctl enable docker",
    "sudo -n systemctl start docker",
    "sudo -n systemctl is-active --quiet docker",

    "echo '========== STEP 8: HOSTNAME =========='",
    "sudo -n hostnamectl set-hostname ${var.server_name}",

    "echo '========== STEP 9: SSH =========='",
    "sudo -n systemctl enable ssh",
    "sudo -n systemctl start ssh",
    "sudo -n systemctl is-active --quiet ssh",

    "echo '========== DOCKER VERSION =========='",
    "docker --version",

    "echo '========== DOCKER COMPOSE VERSION =========='",
    "docker compose version",

    "echo '========== BOOTSTRAP COMPLETED =========='"
  ]
}
}
