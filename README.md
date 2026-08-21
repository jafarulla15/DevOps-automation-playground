"# DevOps-automation-playground" 

**Complete Roadmap**

```
| Step | Work                                 |
| ---: | ------------------------------------ |
|    1 | Prepare Ubuntu VM                    |
|    2 | Create Terraform project             |
|    3 | Terraform server bootstrap           |
|    4 | Install Docker + k3s                 |
|    5 | Kubernetes namespaces/foundation     |
|    6 | Helm + storage                       |
|    7 | Traefik + Ingress                    |
|    8 | SQL Server Express                   |
|    9 | GitHub Container Registry            |
|   10 | Jenkins                              |
|   11 | GitHub → Jenkins → GHCR → Kubernetes |
|   12 | Containerize EARN services           |
|   13 | Reusable Helm chart                  |
|   14 | Deploy EARN backend                  |
|   15 | Deploy EARN frontend + Ingress       |
|   16 | Database migration/configuration     |
|   17 | Prometheus                           |
|   18 | Grafana                              |
|   19 | Loki + Alloy                         |
|   20 | OpenTelemetry Collector              |
|   21 | Loki/Grafana integration             |
|   22 | OpenTelemetry in .NET                |
|   23 | Tempo                                |
|   24 | Alertmanager                         |
|   25 | EARN-specific alerts                 |
|   26 | Production-style Jenkins pipeline    |
|   27 | Image vulnerability scanning         |
|   28 | Automated Helm deployment            |
|   29 | Rollback                             |
|   30 | Terraform cleanup                    |
|   31 | Terraform modules/environments       |
|   32 | Terraform state strategy             |
|   33 | Kubernetes RBAC                      |
|   34 | NetworkPolicies                      |
|   35 | Secrets management                   |
|   36 | Container security                   |
|   37 | Liveness/readiness                   |
|   38 | CPU/memory resource limits           |
|   39 | HPA                                  |
|   40 | SQL Server backup                    |
|   41 | Kubernetes backup                    |
|   42 | Disaster recovery testing            |
|   43 | Load testing                         |
|   44 | Performance analysis                 |
|   45 | CI/CD quality gates                  |
|   46 | Deployment environments              |
|   47 | Grafana dashboards                   |
|   48 | Metrics/logs/traces correlation      |
|   49 | Documentation                        |
|   50 | Full end-to-end testing              |

```
**Suggested Module architecture:**
```
terraform/
│
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── terraform.tfvars
│
├── modules/
│   │
│   ├── server-bootstrap/
│   ├── docker/
│   ├── network/
│   ├── storage/
│   │
│   ├── sqlserver/
│   ├── jenkins/
│   ├── github/
│   ├── registry/
│   │
│   ├── prometheus/
│   ├── grafana/
│   ├── loki/
│   ├── otel-collector/
│   ├── node-exporter/
│   ├── cadvisor/
│   ├── alertmanager/
│   │
│   ├── security/
│   ├── reverse-proxy/
│   ├── ssl/
│   │
│   ├── keycloak/
│   ├── rabbitmq/
│   ├── redis/
│   │
│   ├── microservices/
│   ├── frontend/
│   ├── config/
│   ├── secrets/
│   │
│   ├── backup/
│   ├── monitoring/
│   ├── logging/
│   ├── health-check/
│   └── ci-cd/
│
└── environments/
    └── training/
        ├── main.tf
        ├── variables.tf
        └── terraform.tfvars
```
**Here's View:**

```
                    ROOT TERRAFORM
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
     Platform           Data            Monitoring
        │                 │                 │
     Docker            SQL Server       Prometheus
     Network            Redis            Grafana
     Security           RabbitMQ         Loki
     Storage                              OTel
        │
        └───────────────┐
                        │
                  EARN Application
                        │
             ┌──────────┴──────────┐
             │                     │
          Frontend             Microservices
             │                     │
             └──────────┬──────────┘
                        │
                   Reverse Proxy
```

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

**Step 3.A — Our first Terraform configuration:**
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

**Step 3.B — Configure sudo command password-less for the user:**
**Why need:** 
Terraform cannot interactively type the password, so the command waits which use sudo. 
**Recommended solution: configure passwordless sudo -**
For a Terraform/DevOps automation server, configure the "jafar" user to execute required sudo commands without a password.

**Configure passwordless sudo:**

On Ubuntu:
```
sudo visudo
```
Add this at the bottom:
```
jafar ALL=(ALL) NOPASSWD:ALL
```
Save and exit.
If you're using nano, press:
```
Ctrl+O
Enter
Ctrl+X
```
If you're using vi/vim:
```
Esc
:wq
Enter
```
Verify it
   ```
Log out:
exit
```
Then SSH again:
```
ssh jafar@192.168.238.50
```
Run:
```
sudo -n true
```
If there is no password prompt and no error, passwordless sudo is working.

You can also verify:
```
sudo -n apt-get update
```

**Step 3.C — Try Terraform Command:**
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

**Step 3.D — Try Below also To Run Terraform:**

```
terraform fmt -recursive
       ↓
terraform init
      ↓
terraform validate
      ↓
terraform plan -out=tfplan
      ↓
Review plan
      ↓
terraform apply tfplan
```

**Step 4 — Add Docker Installation Module:**

```
terraform/
│
├── main.tf
├── providers.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
│
└── modules/
    │
    ├── docker/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
```


**Step 5 — Add SQL Server Express Installation and Setup Module:**

```
terraform/
│
├── main.tf
├── providers.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
│
└── modules/
    │
    └── sqlserver/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── terraform.tf   ← ADD THIS
```

**Check the SQL Server connection:**
You can also test locally:
```
nc -zv localhost 1433
```
Expected:
```
Connection to localhost 1433 port [tcp/ms-sql-s] succeeded!
```

**Step 6 — Add Jenkins Module:**

For Terraform → Docker → Jenkins CI/CD architecture, I would make the Jenkins module self-contained so that terraform apply creates a Jenkins instance that is already configured with:
```
Jenkins LTS
Required plugins
JCasC configuration
Admin user
Persistent Jenkins home
Docker CLI
Docker socket access for CI/CD
Jenkins web port 8080
Jenkins agent port 50000
Timezone
Basic security configuration
```
**File Architecture:**

```
terraform/
│
├── main.tf
├── providers.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
│
└── modules/
    │
    ├── docker/
    │
    ├── sqlserver/
    │
    └── jenkins/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        ├── terraform.tf
        ├── Dockerfile
        └── config/
            ├── plugins.txt
            └── jenkins.yaml
```

**Get Jenkins initial password:**

Run:
```
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```
You'll get something like:
```
a9c8e7d6c5b4a3...
```
Open:
```
http://<Ubuntu-IP>:8080
```
Then enter that password.


**Verify Jenkins**

Check container:
```
docker ps
```
You should see something similar to:
```
CONTAINER ID   IMAGE                   PORTS
xxxxxx         jenkins/jenkins:lts    0.0.0.0:8080->8080/tcp
                                      0.0.0.0:50000->50000/tcp
```

**Jenkins plugins:**

You also mentioned wanting CI/CD, GitHub, Docker, Kubernetes, Prometheus/Grafana, etc.
We can make the Terraform module more complete by having Jenkins automatically install plugins such as:

```
Git
GitHub
Pipeline
Pipeline: Stage View
Credentials Binding
Docker Pipeline
Docker
Kubernetes
Kubernetes CLI
SSH Agent
Blue Ocean
```

**Terraform will approximately do:**
```
Terraform
   │
   ├── Create jenkins_home volume
   │
   ├── Build custom Jenkins Docker image
   │       │
   │       ├── Jenkins LTS
   │       ├── Docker CLI
   │       ├── Git
   │       ├── Required plugins
   │       └── JCasC
   │
   └── Create Jenkins container
           │
           ├── :8080
           ├── :50000
           ├── /var/jenkins_home
           └── /var/run/docker.sock
```

**Step 7 — Add Prometheus Module:**

**Knowledge:**
**Why need: Create Monitoring Network**

The Docker network is needed because Prometheus and Grafana are separate Docker containers, but they need to communicate with each other.
Think of the Docker network as a private virtual LAN for your monitoring containers.
Without a monitoring network

You have:
```
Ubuntu Server
│
├── Prometheus container :9090
│
└── Grafana container :3000
```
Grafana needs to connect to Prometheus to query metrics.

If you use a dedicated Docker network, they can communicate using Docker container/service names:
```
Grafana
   │
   │ HTTP
   │ http://prometheus:9090
   ▼
Prometheus
```
This is much cleaner than trying to use the host IP.

What this Terraform code does
```
resource "docker_network" "monitoring" {
  name = "monitoring"
}
```
Terraform creates a Docker network equivalent to:
```
docker network create monitoring
```
You can verify it with:
```
docker network ls
```
You should see:
```
NETWORK ID     NAME          DRIVER
xxxxxxx        monitoring    bridge
```
**So the architecture becomes:**
```
                    Docker Network: monitoring
              ┌──────────────────────────────────┐
              │                                  │
              │   ┌──────────────┐               │
              │   │  Prometheus  │               │
              │   │    :9090     │               │
              │   └──────▲───────┘               │
              │          │                        │
              │          │ PromQL/HTTP            │
              │          │                        │
              │   ┌──────┴───────┐               │
              │   │   Grafana    │               │
              │   │    :3000     │               │
              │   └──────────────┘               │
              │                                  │
              └──────────────────────────────────┘
                         │
                         │
                    Ubuntu Host
```


**File Architecture:**

```
terraform/
│
├── main.tf
├── providers.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
│
├── prometheus/
│   └── prometheus.yml  ← Prometheus configuration
│
└── modules/
    │
    ├── docker/
    │
    ├── sqlserver/
    │
    ├── jenkins/
    │
    ├── prometheus/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf

```
**Knowledge:**
**Why not put prometheus.yml inside modules/prometheus/?:**

You can, but I recommend keeping it outside the module.
The module should be reusable:
```
modules/prometheus/
```
should contain the generic Prometheus infrastructure.

**In short:**
modules/prometheus/ = **how to create Prometheus**
prometheus/prometheus.yml = **what Prometheus should monitor**


**Step 8 — Add Grafana Module:**

**File Architecture:**

```
terraform/
│
├── main.tf
├── providers.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
│
├── prometheus/
│   └── prometheus.yml  ← Prometheus configuration
│
└── modules/
    │
    ├── docker/
    │
    ├── sqlserver/
    │
    ├── jenkins/
    │
    ├── prometheus/
    │
    └── grafana/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf

```


**Important monitoring infrastructure:**
```
                         ┌─────────────────────┐
                         │      EARN App       │
                         │                     │
                         │ .NET APIs           │
                         │ Angular             │
                         │ Microservices       │
                         └──────────┬──────────┘
                                    │
                             /metrics
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │     Prometheus      │
                         │      :9090          │
                         └──────────┬──────────┘
                                    │
                              PromQL queries
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │       Grafana       │
                         │       :3000         │
                         └─────────────────────┘

              ┌─────────────────────────────────────┐
              │             Monitoring              │
              │                                     │
              │ Node Exporter → Server metrics      │
              │ cAdvisor      → Docker metrics      │
              │ Prometheus    → Metrics storage     │
              │ Grafana       → Visualization       │
              │ Loki          → Logs                │
              │ OpenTelemetry → Traces/telemetry    │
              └─────────────────────────────────────┘
```

**One command to see everything:**

**Run:**
```
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
```
**Will get:**
```
NAMES        IMAGE                       STATUS          PORTS
jenkins      jenkins/jenkins:lts        Up ...          0.0.0.0:8080->8080/tcp
prometheus   prom/prometheus:latest     Up ...          0.0.0.0:9090->9090/tcp
grafana      grafana/grafana:latest     Up ...          0.0.0.0:3000->3000/tcp
```
**URLs:**
```
NAMES               IMAGE                    STATUS         PORTS
jenkins             d5bd8c0f799d             Up ...   0.0.0.0:8080->8080/tcp, 0.0.0.0:50000->50000/tcp
sqlserver-express   ba4c8329f48f             Up ...   0.0.0.0:1433->1433/tcp
prometheus          prom/prometheus:latest   Up ...   0.0.0.0:9090->9090/tcp
grafana             grafana/grafana:latest   Up ...   0.0.0.0:3000->3000/tcp
```


**Resulting Architecture:**
```
                         Ubuntu Server
                              │
                         Docker Engine
                              │
                       project_network
                              │
       ┌──────────────┬───────┼───────────┬─────────────┐
       │              │       │           │             │
    Jenkins       SQL Server Redis     RabbitMQ       Vault
       │              │       │           │             │
       │              │       │           │             │
       └──────────────┴───────┼───────────┴─────────────┘
                              │
                       Microservices
                              │
                    OpenTelemetry
                              │
                    ┌─────────┴─────────┐
                    │                   │
                  Loki             Prometheus
                    │                   │
                    │             Alertmanager
                    │                   │
                    └───────┬───────────┘
                            │
                         Grafana


                 Docker Registry
                       │
                       │
                 Jenkins CI/CD
                       │
                       ▼
                Build Docker Image
                       │
                       ▼
                 Push to Registry
                       │
                       ▼
                 Deploy Microservice
```

**Recommended ports**
```
| Component           | Container Port | Host Port |
| ------------------- | -------------: | --------: |
| Loki                |           3100 |      3100 |
| OpenTelemetry gRPC  |           4317 |      4317 |
| OpenTelemetry HTTP  |           4318 |      4318 |
| OTel Metrics        |           8888 |      8888 |
| Redis               |           6379 |      6379 |
| RabbitMQ AMQP       |           5672 |      5672 |
| RabbitMQ Management |          15672 |     15672 |
| Alertmanager        |           9093 |      9093 |
| Vault               |           8200 |      8200 |
| Docker Registry     |           5000 |      5000 |
```

**Important Knowledge: root module vs child modules**

If these variables are actually intended for child modules, declaring them only inside the child module is not enough.

For example, if your structure is:
```
main.tf
variables.tf
terraform.tfvars
```
```
modules/
├── vault/
│   ├── main.tf
│   └── variables.tf
└── rabbitmq/
    ├── main.tf
    └── variables.tf
```
Then the root variables.tf still needs:
```
variable "vault_root_token" {
  description = "HashiCorp Vault root token"
  type        = string
  sensitive   = true
}


variable "rabbitmq_password" {
  description = "RabbitMQ password"
  type        = string
  sensitive   = true
}
```
And your root main.tf should pass them into the modules:
```
module "vault" {
  source = "./modules/vault"


  vault_root_token = var.vault_root_token
}


module "rabbitmq" {
  source = "./modules/rabbitmq"


  rabbitmq_password = var.rabbitmq_password
}
```
The child modules then declare their own variables:
```
variable "vault_root_token" {
  description = "HashiCorp Vault root token"
  type        = string
  sensitive   = true
}
```
and:
```
variable "rabbitmq_password" {
  description = "RabbitMQ password"
  type        = string
  sensitive   = true
}
```


