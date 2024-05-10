# 一键脚本
```bash
bash <(curl -Ls https://raw.githubusercontent.com/passeway/sbnaiveproxy/main/sbnaive.sh)
```
# 安装
下载sing-box
```
bash <(curl -fsSL https://sing-box.app/deb-install.sh)
```
修改/etc/sing-box/config.json
```
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
      "listen_port": 端口,
      "tcp_fast_open": true,
      "sniff": true,
      "sniff_override_destination": true,
      "users": [
        {
          "username": "用户名",
          "password": "密码"
        }
      ],
      "tls": {
        "enabled": true,
        "server_name": "域名",
        "acme": {
          "domain": ["域名"],
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
    }
  ]
}
查看config.json
```
cat /etc/sing-box/config.json
```
启动config.json
```
usr/bin/sing-box run -c /etc/sing-box/config.json
```
启动系统服务
```
systemctl enable sing-box
```
启动sing-box
```
systemctl start sing-box
```
重启sing-box
```
systemctl restart sing-box
```
查看sing-box
```
systemctl status sing-box
```
查看证书
```
ls /usr/local/etc/sing-box/certificates/acme-v02.api.letsencrypt.org-directory/
```


# 卸载
停止并禁用 Sing Box 服务
```
sudo systemctl stop sing-box
sudo systemctl disable sing-box
```
卸载 Sing Box
```
sudo apt-get remove --purge sing-box -y
```
删除配置文件
```
sudo rm -rf /etc/sing-box
sudo rm -f /var/log/singbox.log
sudo rm -rf /usr/local/etc/sing-box
```
重新加载 systemd
```
sudo systemctl daemon-reload
```

