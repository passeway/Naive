停止并禁用 Sing Box 服务
```
sudo systemctl stop sing-box
sudo systemctl disable sing-box
sudo userdel sing-box-user
```
卸载 Sing Box
```
sudo apt-get remove --purge sing-box -y
```
删除配置文件
```
sudo rm -rf /etc/sing-box
```

删除日志文件
```
sudo rm -f /var/log/singbox.log
```

删除数据目录
```
sudo rm -rf /usr/local/etc/sing-box
```
重新加载 systemd
```
sudo systemctl daemon-reload
```

