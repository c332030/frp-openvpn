
# cd /usr/lib/systemd/system/
# cd /lib/systemd/system/

# rm -f frpc.service

# vi frpc.service

# systemctl daemon-reload

# systemctl start frpc.service
# systemctl enable frpc.service

# Created symlink from /etc/systemd/system/multi-user.target.wants/frpc.service to /usr/lib/systemd/system/frpc.service.

[Unit]
Description=FRP to bypass NAT Network
Wants = network-online.target
After=network.target 

[Service] 
Type=simple 
ExecStart=/home/root/program/frp/frpc -c /home/root/program/frp/frpc.ini
#ExecReload=/usr/local/frp/frpc
#ExecStop=/usr/local/frp/frpc

StandardOutput = syslog
StandardError = inherit

PrivateTmp=true 

[Install] 
WantedBy=multi-user.target
