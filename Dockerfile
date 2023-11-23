FROM  tokyo2006/hugo-builder:v0.111

LABEL maintainer="Chen Zeng <rurounikexin@gmail.com>" 

COPY . /opt/apps

WORKDIR /opt/apps

ARG GITHUB_TOKEN

ENTRYPOINT ["./docker-build.sh"]
