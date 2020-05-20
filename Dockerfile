FROM alpine:latest

LABEL maintainer="Chen Zeng <rurounikexin@gmail.com>" 

ENV VERSION 0.71.0

RUN apk add --no-cache git openssl py-pygments curl \
    && curl -L https://github.com/gohugoio/hugo/releases/download/v${VERSION}/hugo_${VERSION}_Linux-64bit.tar.gz | tar -xz \
    && mv hugo /usr/bin/hugo \
    && apk del curl

COPY . /opt/apps

WORKDIR /opt/apps

ARG GITHUB_TOKEN

ENTRYPOINT ["./docker-build.sh"]
