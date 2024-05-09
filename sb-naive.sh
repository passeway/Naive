#!/bin/bash

# 第一步：安装Sing Box
echo "正在安装 Sing Box..."
bash <(curl -fsSL https://sing-box.app/deb-install.sh)


# 随机生成一个 1025 到 65535 之间的端口号
PORT=$(shuf -i 1025-65535 -n 1)

# 用户名和密码
USERNAME="admin"
PASSWORD=$(openssl rand -base64 12)

# 提示用户输入域名
read -p "请输入域名: " DOMAIN

# 检查输入的域名是否为空
if [ -z "$DOMAIN" ]; then
  echo "错误：域名不能为空！"
  exit 1
fi

# 配置内容
/etc/sing-box/config.json=$(cat <<EOF
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
)


# 验证配置
/usr/bin/sing-box run -c /etc/sing-box/config.json


# 第四步：启用并启动 Sing Box
echo "启用并启动 Sing Box..."
systemctl enable sing-box
systemctl start sing-box
systemctl status sing-box

# 输出配置信息
echo "配置完成！"
echo "Naive 代理正在监听端口 $PORT"
echo "用户名：$USERNAME"
echo "密码：$PASSWORD"
echo "使用域名：$DOMAIN"
