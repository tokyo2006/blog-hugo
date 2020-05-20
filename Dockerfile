From  tokyo2006/hugo-builder:latest

COPY . /opt/apps

WORKDIR /opt/apps

ARG GITHUB_TOKEN

ENTRYPOINT ["./docker-build.sh"]
