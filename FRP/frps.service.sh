
# cd /usr/lib/systemd/system/
# cd /lib/systemd/system/

# rm -f frps.service

# vi frps.service

# systemctl daemon-reload

# systemctl start frps.service
# systemctl enable frps.service

# Created symlink from /etc/systemd/system/multi-user.target.wants/frps.service to /usr/lib/systemd/system/frps.service.

[Unit]
Description=FRP to bypass NAT Network
Wants = network-online.target
After=network.target 

[Service] 
Type=simple 
ExecStart=/root/program/frp/frps -c /root/program/frp/frps.ini
#ExecReload=/usr/local/frp/frps
#ExecStop=/usr/local/frp/frps

StandardOutput = syslog
StandardError = inherit

PrivateTmp=true 

[Install] 
WantedBy=multi-user.target
