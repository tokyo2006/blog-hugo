From --platform=arm64 tokyo2006/hugu-builder

COPY . /opt/apps

WORKDIR /opt/apps

ARG GITHUB_TOKEN

ARG GITHUB_REPO

ENTRYPOINT ["./docker-build.sh"]