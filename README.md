"# DevOps-automation-playground" 

**Step 1 — Prepare Ubuntu:**

SSH into your Ubuntu VM and run:
sudo apt update
sudo apt upgrade -y

**Give it a static IP.** DHCP will eventually hand your VM a different address
and every TLS certificate, kubeconfig and inventory entry will break at once.
Either reserve the MAC in your router, or set it in netplan:

```bash
sudo vi /etc/netplan/50-cloud-init.yaml
```

```yaml
network:
  version: 2
  ethernets:
    ens33:                        # check yours with `ip -br link`
      dhcp4: false
      addresses: [192.168.1.50/24]
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses: [1.1.1.1, 8.8.8.8]
```

```bash
sudo chmod 600 /etc/netplan/50-cloud-init.yaml
sudo netplan apply
ip -br addr
```
**If you disconnected from internet after setting up the static IP** DHCP will eventually hand your VM a different address
and every TLS certificate, kubeconfig and inventory entry will break at once.
Either reserve the MAC in your router, or set it in netplan:

Yes. The Netplan configuration itself is mostly correct, but 192.168.1.1 must actually be the gateway of the VMware network your Ubuntu VM is connected to.
Since you're running Ubuntu in VMware on your Windows laptop, this is very likely a VMware network mismatch.

A. First check your current network
Run:
```
ip -br addr
```
Then:
```
ip route
```
And:
```
ip route get 8.8.8.8
```
Also check DNS:
```
resolvectl status
```
The most important thing is the output of:
```
ip route
```
You should see something like:
```
default via 192.168.1.1 dev ens33
192.168.1.0/24 dev ens33 proto kernel scope link src 192.168.1.50
```
If you don't actually have a 192.168.1.1 gateway, internet won't work.

B. Very likely issue: VMware network

In VMware, check:
```
VM → Settings → Network Adapter
```
You will normally have one of these:
```
NAT
```
This is usually the easiest choice for your setup.

```
Bridged
```
The VM gets an IP from the same network as your physical Windows machine.
```
Host-only
```

⚠️ Host-only normally does not provide Internet access.

For your DevOps training VM, I'd recommend NAT.

C. If VMware is using NAT

Don't assume:
```
via: 192.168.1.1
```
Your VMware NAT gateway could be something like:
```
192.168.174.2
```
or:
```
192.168.237.2
```
depending on your VMware configuration.
Check the VMware network configuration on Windows.

Open:
```
VMware → Edit → Virtual Network Editor
```
Look at:
```
VMnet8
```
For example, you might see:
```
Subnet IP:      192.168.174.0
Subnet mask:    255.255.255.0
NAT Gateway:    192.168.174.2
```
Then your Ubuntu static configuration should use that network.
For example:
```
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: false
      addresses:
        - 192.168.174.50/24
      routes:
        - to: default
          via: 192.168.174.2
      nameservers:
        addresses:
          - 1.1.1.1
          - 8.8.8.8
```
Then:
```
sudo netplan apply
```

**Enable SSH server on Ubuntu:** 
```
sudo apt update
sudo apt install openssh-server -y
sudo systemctl enable --now ssh
```

**Ensure SSH key exists:** 
On the machine running Terraform:
```
ls -la ~/.ssh/
```
You should have:
```
id_ed25519
id_ed25519.pub
```
**Easiest way to install the key**

From the machine running Terraform:
```
ssh-copy-id -i ~/.ssh/id_ed25519.pub jafar@192.168.238.50
```
It may ask for the jafar password once.

Then test:
```
ssh -i ~/.ssh/id_ed25519 jafar@192.168.238.50
```
If you can login without entering a password, Terraform should be able to authenticate.

**Step 2 — Install Terraform:**

**Install Terraform**
On Ubuntu, install the current Terraform package from HashiCorp's official repository.
HashiCorp Terraform installation documentation : 
```
https://developer.hashicorp.com/terraform/install?utm_source=chatgpt.com
```
Then verify:
```
terraform version
```
Also install Git:
```
sudo apt install -y git curl wget unzip ca-certificates gnupg
```
Verify:
```
git --version
```

**Step 3 — Create the Terraform project:**
I recommend keeping your infrastructure separate from your EARN application source code.

Create this initial structure:
```
earn-infrastructure/
├── terraform/
│   └── training/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── providers.tf
│       └── terraform.tfvars.example
│
├── scripts/
│
├── k8s/
│
├── helm/
│
├── jenkins/
│
├── monitoring/
│
├── docs/
│
└── README.md
```

**Step 2.A — Our first Terraform configuration:**
Go into:
```
cd terraform/training
```

Create providers.tf:
```
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}
```

Create variables.tf:
```
variable "server_name" {
  description = "Training server hostname"
  type        = string
  default     = "earn-training"
}

variable "ssh_user" {
  description = "Linux user used for remote configuration"
  type        = string
}

variable "server_ip" {
  description = "IP address of the existing Linux VM"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key"
  type        = string
}
```
Create terraform.tfvars.example:
```
server_name           = "earn-training"
ssh_user              = "your-linux-user"
server_ip             = "192.168.1.150"
ssh_private_key_path  = "~/.ssh/id_ed25519"
```
Do not commit your real terraform.tfvars.

Create .gitignore in the project root:
```
.terraform/
*.tfstate
*.tfstate.*
terraform.tfvars
*.tfplan
crash.log
```

**Knowledge — Terraform version and providers:**

**A. required_providers:**
```
required_providers {
}
```

This tells Terraform:
```
"These are the external providers my Terraform configuration needs."
```
A provider is a plugin that allows Terraform to communicate with something.

For example:
```
Terraform
   │
   ├── AWS Provider ─────── AWS
   │
   ├── Azure Provider ───── Azure
   │
   ├── Kubernetes Provider ─ Kubernetes
   │
   └── Null Provider ────── Local Terraform operations
```

**B. null = { ... }**
```
null = {
```
null is the local name you're giving to the provider.

For example, later you can write:
```
resource "null_resource" "example" {
}
```
Here:
```
null
 │
 └── Provider name
```

**C. source = "hashicorp/null"**
. source = "hashicorp/null"
```
source = "hashicorp/null"
```
This tells Terraform exactly where the provider comes from.
The format is generally:
```
registry_namespace/provider_name
```
So:
```
hashicorp/null
   │       │
   │       └── Provider
   └────────── Organization
```
Terraform downloads this provider from the Terraform Registry.

**D. Why use a provider?**

Suppose your Terraform code contains:
```
resource "null_resource" "setup" {
  provisioner "local-exec" {
    command = "echo Hello"
  }
}
```
Terraform needs to know what null_resource means.

The hashicorp/null provider supplies that resource type.

Without the provider declaration, Terraform won't know which provider should handle it.

**Step 2.B — Try Terraform Command:**
```
terraform init
      ↓
terraform validate
      ↓
terraform plan
      ↓
terraform apply
      ↓
verify
```



