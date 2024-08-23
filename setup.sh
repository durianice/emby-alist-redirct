#!/bin/bash

NGINX_TEMP_DIR="./nginx_for_emby/emby2Alist/nginx"
NGINX_ENV_FILE="/home/.env.emby_nginx"
NGINX_WORK_DIR="./nginx_workdir"

if [ ! -d "$NGINX_TEMP_DIR" ] || [ -z "$(ls -A "$NGINX_TEMP_DIR" 2>/dev/null)" ]; then
    echo "请先使用 install.sh 拉取仓库文件"
    exit 1
fi

mkdir -m 775 -p "${NGINX_WORK_DIR}"
cp -r "${NGINX_TEMP_DIR}" "${NGINX_WORK_DIR}"

get_vars() {
    local VAR_NAME=$1
    local TIPS=$2
    local DEFAULT=$3

    # 如果 .env 文件存在，读取变量值
    if [ -f "$NGINX_ENV_FILE" ]; then
        source "$NGINX_ENV_FILE"
    fi

    local VALUE=${!VAR_NAME}
    if [ -z "$VALUE" ]; then
        read -p "${TIPS} - [${DEFAULT}]: " INPUT
        VALUE="${INPUT:-$DEFAULT}"
        if [ -z "$VALUE" ]; then
            echo "输入无效，请重新执行 setup.sh 开始"
            rm -rf "${NGINX_WORK_DIR}"
            exit 1
        fi
        echo "$VAR_NAME=\"$VALUE\"" >> "$NGINX_ENV_FILE"
    fi
    echo $VALUE
}

replace_vars() {
    local FILE=$1
    local TIPS=$2
    local SEARCH_STRING=$3
    local ENV_VAR_NAME=$4
    if [ ! -f "$FILE" ]; then
        echo "文件不存在 $FILE"
        return 1
    fi
    REPLACE_STRING=$(get_vars "$ENV_VAR_NAME" "$TIPS" "$SEARCH_STRING")
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|${SEARCH_STRING}|${REPLACE_STRING}|g" "$FILE"
    else
        sed -i "s|${SEARCH_STRING}|${REPLACE_STRING}|g" "$FILE"
    fi
    echo "已将文件 $FILE 中的 '$SEARCH_STRING' 替换为 '$REPLACE_STRING'"
}

replace_vars "${NGINX_WORK_DIR}/nginx/conf.d/constant.js" "请输入EMBY服务地址(http://xxxx:1234)" "{{EMBY_HOST}}" "EMBY_HOST"
replace_vars "${NGINX_WORK_DIR}/nginx/conf.d/constant.js" "请输入EMBY API KEY"  "{{EMBY_API_KEY}}" "EMBY_API_KEY"
replace_vars "${NGINX_WORK_DIR}/nginx/conf.d/constant.js" "请输入挂载目录(/mnt)" "{{MEDIA_MOUNT_PATH}}" "MEDIA_MOUNT_PATH"
replace_vars "${NGINX_WORK_DIR}/nginx/conf.d/config/constant-mount.js" "请输入ALIST服务地址(http://xxxx:1234)" "{{ALIST_ADDR}}" "ALIST_ADDR"
replace_vars "${NGINX_WORK_DIR}/nginx/conf.d/config/constant-mount.js" "请输入ALIST TOKEN" "{{ALIST_TOKEN}}" "ALIST_TOKEN"
replace_vars "${NGINX_WORK_DIR}/nginx/conf.d/config/constant-mount.js" "请输入ALIST外网地址(http://xxxx:1234)" "{{ALIST_PUBLIC_ADDR}}" "ALIST_PUBLIC_ADDR"
replace_vars "${NGINX_WORK_DIR}/nginx/conf.d/includes/http.conf" "请输入最终访问端口(8097)" "{{HTTP_PORT}}" "HTTP_PORT"
replace_vars "${NGINX_WORK_DIR}/nginx/conf.d/includes/server-group.conf" "请输入EMBY内网IP:HOST(xxxx:1234)" "{{DOCKER_IP_HOST}}" "DOCKER_IP_HOST"
