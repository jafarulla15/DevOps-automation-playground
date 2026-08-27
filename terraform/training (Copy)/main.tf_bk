resource "null_resource" "server_bootstrap" {

  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = var.ssh_user
    private_key = file(pathexpand(var.ssh_private_key_path))
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${var.server_name}",

      "sudo apt-get update",

      "sudo apt-get install -y ca-certificates curl wget git unzip jq vim htop net-tools ufw",

      "sudo systemctl enable ssh",

      "sudo systemctl start ssh",

      "echo 'EARN training server bootstrap completed'"
    ]
  }
}
