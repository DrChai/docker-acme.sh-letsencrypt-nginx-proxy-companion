acme.sh-letsencrypt-nginx-proxy-companion is forked from original [letsencrypt-nginx-proxy-companion](https://github.com/jwilder/nginx-proxy), to support Let's Encrypt V2 wildcard api by using [acme.sh](acme.sh)


#### Usage

To use it with original [nginx-proxy](https://github.com/jwilder/nginx-proxy) container you must declare 3 writable volumes from the [nginx-proxy](https://github.com/jwilder/nginx-proxy) container:
* `/etc/nginx/certs` to create/renew Let's Encrypt certificates


Example of use:

* First start nginx with the 3 volumes declared:

   **Note:** we no longer need volumes of `/etc/nginx/vhost.d` and `/usr/share/nginx/html` when using V2 api
```bash
$ docker run -d -p 80:80 -p 443:443 \
    --name nginx-proxy \
    -v /path/to/certs:/etc/nginx/certs:ro \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    --label com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy \
    jwilder/nginx-proxy
```
The "com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy" label is needed so that the letsencrypt container knows which nginx proxy container to use.

* Second start this container:

   **Note:** some additonal environment variable(s) is(are) required when using v2 depends on what your dns provider is. READ [acme.sh dns api](https://github.com/Neilpang/acme.sh/tree/master/dnsapi)
```bash
$ docker run -d \
    -v /path/to/certs:/etc/nginx/certs:rw \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    --volumes-from nginx-proxy \
    -e "DO_API_KEY=yourdgonkey" \
    carrycat/acme.sh-letsencrypt-nginx-proxy-companion
```

#### Let's Encrypt

Declare the `LETSENCRYPT_HOST` and `LETSENCRYPT_DNS` environment variables in each to-be-proxied application containers.

* The `LETSENCRYPT_HOST` to get wildcard certs, please only include your base domain `example.com` and your wildcard domian `*.example.com`
* The `LETSENCRYPT_DNS` is additional variable to be used in [acme.sh dns api](https://github.com/Neilpang/acme.sh/tree/master/dnsapi) 

##### Example:
```bash
$ docker run -d \
    --name example-app \
    -e "VIRTUAL_HOST=example.com,www.example.com,mail.example.com" \
    -e "LETSENCRYPT_HOST=example.com,*.example.com" \
    -e "LETSENCRYPT_DNS=dns_dgon" \
    tutum/apache-php
```

##### Example of docker-compose:

```yml
version: '3'
services:
  acme:
    container_name: acme
    image: carrycat/acme.sh-letsencrypt-nginx-proxy-companion
    environment:
      - DO_API_KEY=digitaloceankey[optional]
      - GD_Key=godaddykey[optional]
      - GD_Secret=godaddysecret[optional]
      - NGINX_PROXY_CONTAINER=${NGINX_WEB:-acme-nginx-proxy}
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./certs:/etc/nginx/certs
  nginx-proxy:
    labels:
        com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy: "true"
    image: jwilder/nginx-proxy
    container_name: acme-nginx-proxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - ./certs:/etc/nginx/certs:ro

networks:
  default:
    external:
      name: ${NETWORK:-webproxy}
```
