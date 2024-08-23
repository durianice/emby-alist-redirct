#!/bin/bash

cd /opt/
git clone https://github.com/durianice/emby-alist-redirct.git
cd emby-alist-redirct
git config --file=.gitmodules submodule.nginx_for_emby.url https://github.com/durianice/embyExternalUrl.git
cd nginx_for_emby
git submodule update --init --recursive
cd ..

ARCH=$(uname -m)
if [ "$ARCH" == "armv7l" ] || [ "$ARCH" == "armv8l" ] || [ "$ARCH" == "aarch64" ]; then
    REPLACE_STRING="emby/embyserver_arm64v8"
else
    REPLACE_STRING="emby/embyserver"
fi
sed -i "s|EMBY_IMAGE_NAME|${REPLACE_STRING}|g" docker-compose.yml

echo "请修改 docker-compose.yml 文件中的环境变量，然后运行 docker compose up -d 启动容器"
echo "查看容器内网IP: docker compose ps -q | xargs docker inspect -f '{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'"