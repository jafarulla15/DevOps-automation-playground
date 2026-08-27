# modules/nginx

Runs Nginx as a Docker container and reverse-proxies to one or more
application containers, keyed by a `applications` map — one module call can
front any number of apps. Routing is by **Docker container name** over a
shared network, not by host port.

## Integration contract

For Nginx to reach an application container by name, that container **must**:

1. Be attached to the same Docker network passed as `var.network_name`
   (Docker's embedded DNS only resolves container names between containers
   on the same user-defined network).
2. Be named exactly what you set as `upstream_container` for that entry in
   `var.applications`.

This module does not control how application containers are created — apps
deployed via [`modules/jenkins-scm-pipeline`](../jenkins-scm-pipeline/README.md)
run whatever `docker run` command lives in that app's own `Jenkinsfile`,
outside Terraform's reach. That `Jenkinsfile` must include matching
`--name`/`--network` flags, e.g.:

```bash
docker run -d \
  --name earn-api \
  --network application \
  --restart unless-stopped \
  earn-registry/earn-api:latest
```

If you instead deploy via [`modules/jenkins-pipeline`](../jenkins-pipeline/README.md)
(the inline-Groovy pipeline module), set that module's `docker_network`
variable to the same network name and its generated Deploy stage will attach
containers to it automatically.

## Example usage

```hcl
resource "docker_network" "application" {
  name = "application"
}

module "nginx" {
  source = "./modules/nginx"

  network_name = docker_network.application.name

  certs_dir = "${path.root}/certs" # only needed if any app below sets enable_tls

  applications = {
    earn-api = {
      server_name        = "api.earn.local"
      upstream_container = "earn-api"
      upstream_port      = 8080
    }

    earn-web = {
      server_name              = "earn.local"
      upstream_container       = "earn-web"
      upstream_port            = 80
      enable_tls               = true
      ssl_certificate_file     = "earn.local.crt"
      ssl_certificate_key_file = "earn.local.key"
    }
  }
}
```

## TLS

Certificate and key files are never passed as Terraform variable values (they
would land in state as plaintext). Instead, place the files on the host under
`var.certs_dir` and reference them by filename via `ssl_certificate_file` /
`ssl_certificate_key_file`; the whole directory is bind-mounted read-only
into the container at `/etc/nginx/certs`. Generating those files (self-signed
`openssl req` for a lab, or certbot/ACME for anything real) is outside this
module's scope.

## Variables

See `variables.tf`. Only `network_name` is required; every application entry
requires `server_name`, `upstream_container`, and `upstream_port`. See the
inline validations for the TLS-related requirements.

## Outputs

- `container_name`, `http_port`, `https_port`
- `server_names` — the configured `server_name` per application, keyed like
  `var.applications`

## How config is generated

`main.tf` renders `templates/nginx.conf.tpl` (static) and
`templates/vhost.conf.tpl` (once per `var.applications` entry) to
`generated/` inside this module directory via `local_file`, then bind-mounts
both into the container read-only. `generated/` is Terraform output, not
source — it's excluded via `.gitignore`; do not edit it by hand.

## Gotchas

- Removing an entry from `var.applications` deletes its rendered vhost file
  and Terraform will recreate the Nginx container to pick up the change
  (bind-mounted directories aren't watched for changes; `docker_container`
  in this repo isn't configured to reload on file change, so a container
  replace is expected on any config edit).
- This module only creates the Nginx container — it does not create
  `var.network_name` itself. Create that Docker network at the root level
  (or reuse an existing one, e.g. `docker_network.monitoring`) and pass its
  name in.
