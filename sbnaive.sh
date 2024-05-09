#!/bin/bash

# 确保脚本在遇到错误时退出，并打印命令
set -e


# 安装 Sing Box
echo "正在安装 Sing Box..."
bash <(curl -fsSL https://sing-box.app/deb-install.sh) || {
    echo "Sing Box 安装失败！请检查网络连接或安装脚本来源。"
    exit 1
}

# 随机生成一个 1025 到 65535 之间的端口号
PORT=$(shuf -i 1025-65535 -n 1)

# 用户名和随机密码
USERNAME="admin"
PASSWORD=$(openssl rand -base64 6)

# 提示用户输入域名，并验证格式
read -p "请输入域名: " DOMAIN

# 检查域名是否为空
if [[ -z "$DOMAIN" ]]; then
  echo "错误：域名不能为空！"
  exit 1
fi

# 验证域名格式
if ! [[ "$DOMAIN" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
  echo "错误：域名格式不正确！请提供有效的域名。"
  exit 1
fi

# 配置文件位置
CONFIG_FILE="/etc/sing-box/config.json"

# 确保目录存在
sudo mkdir -p "$(dirname "$CONFIG_FILE")"

# 写入配置
sudo tee "$CONFIG_FILE" <<EOF > /dev/null
{
  "log": {
    "level": "info",
    "timestamp": true,
    "output": "/var/log/singbox.log"
  },
  "inbounds": [
    {
      "type": "naive",
      "tag": "naive-in",
      "network": "tcp",
      "listen": "::",
      "listen_port": $PORT,
      "tcp_fast_open": true,
      "sniff": true,
      "sniff_override_destination": true,
      "users": [
        {
          "username": "$USERNAME",
          "password": "$PASSWORD"
        }
      ],
      "tls": {
        "enabled": true,
        "server_name": "$DOMAIN",
        "acme": {
          "domain": ["$DOMAIN"],
          "data_directory": "/usr/local/etc/sing-box",
          "email": "admin@gmail.com",
          "provider": "letsencrypt"
        }
      }
    }
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct"
    },
    {
      "type": "block",
      "tag": "block"
    }
  ]
}
EOF

# 检查配置文件是否成功写入
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "配置文件写入失败！"
    exit 1
fi

# 启用并启动 Sing Box
echo "Sing Box已成功启动 NaïveProxy安装完成"
sudo systemctl enable sing-box || {
    echo "无法启用 Sing Box 服务！"
    exit 1
}

sudo systemctl start sing-box || {
    echo "无法启动 Sing Box 服务！"
    exit 1
}

# 检查服务状态
if ! sudo systemctl is-active --quiet sing-box; then
    echo "Sing Box 服务未成功启动！"
    sudo systemctl status sing-box
    exit 1
fi

cat <<EOF
{
  "listen": "socks://127.0.0.1:1080",
  "proxy": "https://$USERNAME:$PASSWORD@$DOMAIN:$PORT"
}
EOF

