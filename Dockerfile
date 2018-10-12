FROM alpine:3.8

# Install wget and install/updates certificates
RUN apk add --no-cache --virtual .run-deps \
    bash \
    ca-certificates \
    curl \
    jq \
    openssl \
    coreutils \
    socat \
    wget \
    && update-ca-certificates

LABEL maintainer="Haolun C. <edwardc@acrossor.com>"

ENV DOCKER_GEN_VERSION 0.7.4
ENV AUTO_UPGRADE=1 \
    LE_WORKING_DIR=/acme.sh \
    LE_CONFIG_HOME=/acmecerts
ENV DEBUG=false \
    DOCKER_HOST=unix:///var/run/docker.sock

RUN wget --quiet https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-alpine-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
 && tar -C /usr/local/bin -xvzf docker-gen-alpine-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
 && rm /docker-gen-alpine-linux-amd64-$DOCKER_GEN_VERSION.tar.gz
RUN wget -O- https://get.acme.sh | sh && crontab -l | sed 's#> /dev/null##' | crontab -


COPY /app/ /app/

WORKDIR /app

ENTRYPOINT [ "/bin/bash", "/app/entrypoint.sh" ]
CMD [ "/bin/bash", "/app/start.sh" ]

