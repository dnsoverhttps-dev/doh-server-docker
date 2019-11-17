##
# I refer to the following file.
# https://github.com/piccobit/dns-over-https-docker/blob/master/Dockerfile

# stage 1 - build

from golang:latest as Builder

env DOH_VERSION=2.0.1

add https://github.com/m13253/dns-over-https/archive/v${DOH_VERSION}.tar.gz /tmp

run tar -xf /tmp/v${DOH_VERSION}.tar.gz -C /tmp && \
    cd /tmp/dns-over-https-${DOH_VERSION} && \
    make && \
    cp /tmp/dns-over-https-${DOH_VERSION}/doh-server/doh-server \
        /usr/bin/doh-server

# stage 2 - make Image

from alpine:latest

run apk upgrade && \
    apk add --update libc6-compat libstdc++ && \
    apk add --no-cache ca-certificates && \
    addgroup -g 1500 doh && \
    adduser -D -G doh -u 1500 doh

volume /etc/doh-server

copy --from=Builder /usr/bin/doh-server /usr/bin/doh-server

expose 80

workdir /

user doh

label description="doh-server-docker with dockerizing m13253's software"
label maintainer="dnsoverhttps org <dnsoverhttps.dev>"

cmd ["doh-server", "-conf", "/etc/doh-server/doh-server.conf", "-verbose"]