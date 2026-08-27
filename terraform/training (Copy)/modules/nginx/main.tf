resource "local_file" "nginx_conf" {
  filename = "${path.module}/generated/nginx.conf"
  content  = templatefile("${path.module}/templates/nginx.conf.tpl", {})
}

resource "local_file" "vhost" {
  for_each = var.applications

  filename = "${path.module}/generated/conf.d/${each.key}.conf"
  content = templatefile("${path.module}/templates/vhost.conf.tpl", {
    server_name              = each.value.server_name
    upstream_container       = each.value.upstream_container
    upstream_port            = each.value.upstream_port
    client_max_body_size     = each.value.client_max_body_size
    enable_tls               = each.value.enable_tls
    ssl_certificate_file     = each.value.ssl_certificate_file
    ssl_certificate_key_file = each.value.ssl_certificate_key_file
  })
}

resource "docker_container" "nginx" {
  name    = var.container_name
  image   = var.image
  restart = "unless-stopped"

  ports {
    internal = 80
    external = var.http_port
  }

  ports {
    internal = 443
    external = var.https_port
  }

  volumes {
    host_path      = abspath(local_file.nginx_conf.filename)
    container_path = "/etc/nginx/nginx.conf"
    read_only      = true
  }

  volumes {
    host_path      = abspath("${path.module}/generated/conf.d")
    container_path = "/etc/nginx/conf.d"
    read_only      = true
  }

  dynamic "volumes" {
    for_each = var.certs_dir != null ? [var.certs_dir] : []
    content {
      host_path      = abspath(volumes.value)
      container_path = "/etc/nginx/certs"
      read_only      = true
    }
  }

  networks_advanced {
    name = var.network_name
  }

  depends_on = [local_file.nginx_conf, local_file.vhost]
}
