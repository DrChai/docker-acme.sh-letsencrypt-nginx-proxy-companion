dockergen: docker-gen -watch -notify '/app/update_ssl' -wait 15s:60s /app/letsencrypt_service_data.tmpl /app/letsencrypt_service_data
cron: cron -f || crond -f