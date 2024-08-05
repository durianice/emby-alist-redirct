#!/bin/bash

git clone https://github.com/durianice/emby-alist-redirct.git
cd emby-alist-redirct

# 更新子模块的 URL 并初始化子模块
git config --file=.gitmodules submodule.nginx_for_emby.url https://github.com/durianice/embyExternalUrl.git
cd nginx_for_emby
git submodule update --init --recursive

ARCH=$(uname -m)

# 返回主目录并启动 Docker Compose
cd ..

if [ "$ARCH" == "armv7l" ] || [ "$ARCH" == "armv8l" ] || [ "$ARCH" == "aarch64" ]; then
    COMPOSE_FILE="docker-compose-arm.yml"
else
    COMPOSE_FILE="docker-compose-amd.yml"
fi

cp ${COMPOSE_FILE} docker-compose.yml

docker compose up -d

# 列出所有容器的名称和 IP 地址
docker compose ps -q | xargs docker inspect -f '{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'

# 创建目录
mkdir -p /mnt/strm115/ && chmod 777 /mnt