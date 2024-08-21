#!/bin/bash

DIR="./nginx_for_emby/emby2Alist/nginx"
ENV_FILE="/home/.env.emby_nginx"

# 检查目录是否存在且不为空
if [ ! -d "$DIR" ] || [ -z "$(ls -A "$DIR" 2>/dev/null)" ]; then
    echo "The directory either does not exist or is empty."
    exit 1
fi

mkdir -m 775 -p ./nginx_workdir
cp -r "${DIR}" "./nginx_workdir"

# 读取或提示用户输入，并保存到 .env 文件
get_or_set_env_var() {
    local VAR_NAME=$1
    local TIPS=$2
    local DEFAULT=$3

    # 如果 .env 文件存在，读取变量值
    if [ -f "$ENV_FILE" ]; then
        source "$ENV_FILE"
    fi

    local VALUE=${!VAR_NAME}

    # 如果变量为空，提示用户输入
    if [ -z "$VALUE" ]; then
        read -p "${TIPS} - [${DEFAULT}]: " INPUT
        VALUE="${INPUT:-$DEFAULT}"

        # 检查输入是否为空
        if [ -z "$VALUE" ]; then
            echo "No input detected. Exiting..."
            rm -rf ./nginx_workdir
            exit 1
        fi

        # 将输入保存到 .env 文件
        echo "$VAR_NAME=\"$VALUE\"" >> "$ENV_FILE"
    fi

    echo $VALUE
}

# 替换字符串的函数
replace_string_in_file() {
    local FILE=$1
    local TIPS=$2
    local SEARCH_STRING=$3
    local ENV_VAR_NAME=$4

    # 检查文件是否存在
    if [ ! -f "$FILE" ]; then
        echo "File not found!"
        return 1
    fi

    # 获取或设置环境变量
    REPLACE_STRING=$(get_or_set_env_var "$ENV_VAR_NAME" "$TIPS" "$SEARCH_STRING")

    # 检测系统类型并使用适当的 sed 语法
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|${SEARCH_STRING}|${REPLACE_STRING}|g" "$FILE"
    else
        sed -i "s|${SEARCH_STRING}|${REPLACE_STRING}|g" "$FILE"
    fi

    echo "Replaced all occurrences of '$SEARCH_STRING' with '$REPLACE_STRING' in $FILE."
}

# 替换操作
replace_string_in_file "./nginx_workdir/nginx/conf.d/constant.js" "请输入EMBY服务地址(http://xxxx:1234)" "{{EMBY_HOST}}" "EMBY_HOST"
replace_string_in_file "./nginx_workdir/nginx/conf.d/constant.js" "请输入EMBY API KEY"  "{{EMBY_API_KEY}}" "EMBY_API_KEY"
replace_string_in_file "./nginx_workdir/nginx/conf.d/constant.js" "请输入挂载目录(/mnt)" "{{MEDIA_MOUNT_PATH}}" "MEDIA_MOUNT_PATH"
replace_string_in_file "./nginx_workdir/nginx/conf.d/config/constant-mount.js" "请输入ALIST服务地址(http://xxxx:1234)" "{{ALIST_ADDR}}" "ALIST_ADDR"
replace_string_in_file "./nginx_workdir/nginx/conf.d/config/constant-mount.js" "请输入ALIST TOKEN" "{{ALIST_TOKEN}}" "ALIST_TOKEN"
replace_string_in_file "./nginx_workdir/nginx/conf.d/config/constant-mount.js" "请输入ALIST外网地址(http://xxxx:1234)" "{{ALIST_PUBLIC_ADDR}}" "ALIST_PUBLIC_ADDR"
replace_string_in_file "./nginx_workdir/nginx/conf.d/includes/http.conf" "请输入最终访问端口(8097)" "{{HTTP_PORT}}" "HTTP_PORT"
replace_string_in_file "./nginx_workdir/nginx/conf.d/includes/server-group.conf" "请输入EMBY内网IP:HOST(xxxx:1234)" "{{DOCKER_IP_HOST}}" "DOCKER_IP_HOST"
