
# 服务器配置文件
vi /etc/openvpn/server.conf

# 启动服务
systemctl start openvpn@server
systemctl enable openvpn@server

systemctl restart openvpn@server

systemctl status openvpn@server

# 配置放火墙

# 开启转发
vi /etc/sysctl.conf 
  net.ipv4.ip_forward = 1
sysctl -p

mv dh.pem dh2048.pem
mv server.key ta.key
