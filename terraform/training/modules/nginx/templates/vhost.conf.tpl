%{ if enable_tls ~}
server {
    listen 80;
    server_name ${server_name};

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name ${server_name};

    ssl_certificate     /etc/nginx/certs/${ssl_certificate_file};
    ssl_certificate_key /etc/nginx/certs/${ssl_certificate_key_file};

    client_max_body_size ${client_max_body_size};

    location / {
        proxy_pass http://${upstream_container}:${upstream_port};
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
%{ else ~}
server {
    listen 80;
    server_name ${server_name};

    client_max_body_size ${client_max_body_size};

    location / {
        proxy_pass http://${upstream_container}:${upstream_port};
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
%{ endif ~}
