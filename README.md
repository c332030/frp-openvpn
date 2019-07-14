# frp-openvpn
内网穿透VPN搭建

公司电脑是内网，但是我习惯用自己电脑，毕竟 9 代 i7 + 32G内存，但是这样下班后或者出差就很不方便，于是想搭个 VPN。
PS：期间测试了 FRP + SS 的解决方案，但是没成功

版本信息：
>CentOS-7-x86_64-Minimal-1810
OpenVPN 2.4.7
frp_0.27.0_linux_amd64

>安装教程见附录博客或者github，百度也行，就不重复了，配置文件里标注了这次搭建的重点
记得配置防火墙，我直接把防火墙关了

# FRP 服务器 配置文件
```
[common]
bind_port = 7000
```

# FRP 客户端 配置文件
```
[common]
server_addr = xxx.c332030.com
server_port = 7000

[ssh]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = 12822

[vpn]
type = udp
local_port = 1194
remote_port = 1194
```

# FRP 设置为服务，客户端和服务器没区别，就是把改成 frpc 改成 frps
```
# cd /usr/lib/systemd/system/
# cd /lib/systemd/system/

# rm -f frpc.service

# vi frpc.service

# systemctl daemon-reload

# systemctl start frpc.service
# systemctl enable frpc.service


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

```

#OpenVPN 服务器配置文件
```
# 密码验证脚本，里面直接 exit 0 就跳过了验证
# 有的教程写的是 via-files ，但是获取不到用户名密码，可能是 OpenVPN 版本问题
auth-user-pass-verify checkpsw.sh via-env 

# 不验证证书，client-cert-not-required 过期了，启动 OpenVPN 会提示
verify-client-cert none

username-as-common-name

# 此处级别必须是 3，2 的时候 checkpsw.sh 获取不到密码
script-security 3

port 1194
proto udp
dev tun

ca ca.crt
cert server.crt
key server.key  # This file should be kept secret

dh dh2048.pem

# 此处设置为默认的 10.8.0.1 会启动失败，不懂的用我这个
server 10.8.0.0 255.255.255.0

ifconfig-pool-persist ipp.txt

# 转发的地址，公司内网是 192.168.9.xxx，192.168.25.xxx，干脆 192.168.xxx.xxx 全部转发
push "route 192.168.0.0 255.255.0.0"

# 会转发所有，不需要
# push "redirect-gateway def1 bypass-dhcp"

# DNS 不解释
push "dhcp-option DNS 119.29.29.29"
push "dhcp-option DNS 223.5.5.5"

# 客户端连接客户端？复制过来的
client-to-client

keepalive 10 120
cipher AES-256-CBC
comp-lzo
user nobody
group nobody

persist-key
persist-tun

status openvpn-status.log
verb 3
explicit-exit-notify 1

```

# OpenVPN 客户端配置 证书版
```

client
proto udp
dev tun

remote xxx.c332030.com 1194
#remote 192.168.25.128 1194

ca ca.crt   
cert c.crt
key c.key      #对应所下载的证书

resolv-retry infinite
nobind
mute-replay-warnings

keepalive 20 120
comp-lzo
#user openvpn
#group openvpn

persist-key
persist-tun
status openvpn-status.log
log-append openvpn.log
verb 3
mute 20

remote-cert-tls server
```

# OpenVPN 客户端配置 用户名密码版
```
# 密码配置文件，不加文件位置会提示输入用户名密码
# auth-user-pass
auth-user-pass login.conf

#不加会有警告，不加也没关系
auth-nocache

#不加会有警告
keysize 256

client
dev tun
proto udp

# FRP 设置的服务器地址
remote xxx.c332030.com 1194


resolv-retry infinite
nobind

persist-key
persist-tun

# 这个不能少，密码验证注释 cert 和 key
ca ca.crt

#不加会有警告
cipher AES-256-CBC

#不加会有警告
comp-lzo

#日志级别
verb 3

```

附录：

我搭建参考过的博客

按这里操作可以成功搭建 VPN，但是只能证书登录，且使用 FRP 时，证书也无法登录
[1 - 创建 OpenVPN 证书，easy-rsa 2.x 跳过，生成教程在第二步，本人未测试](https://blog.rj-bai.com/post/136.html)
[2 - OpenVPN 服务器配置](https://blog.rj-bai.com/post/132.html)
[3 - OpenVPN 客户端配置](https://blog.rj-bai.com/post/78.html#menu_index_14)

使用密码验证可以使用 FRP
[1 - 同上](#)
[2 - OpenVPN 服务器配置，略微有差别](http://www.ifzhai.com/article.php?id=8)
[3 - 重点，密码验证，我参考了这里](http://www.ifzhai.com/article.php?id=80)
