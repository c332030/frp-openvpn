
# 安装
yum -y install openvpn easy-rsa


# Server
cp -r /usr/share/easy-rsa/ /etc/openvpn/easy-rsa
cd /etc/openvpn/easy-rsa/

\rm 3 3.0
cd 3.0.3/

find / -type f -name "vars.example" | xargs -i cp {} . && mv vars.example vars


#创建空的pki
./easyrsa init-pki  

#创建新的CA，不使用密码
./easyrsa build-ca nopass

# 创建服务端证书
./easyrsa gen-req server nopass 

# 签约服务端证书
./easyrsa sign server server

#创建 Diffie-Hellman
./easyrsa gen-dh


#Client
cp -r /usr/share/easy-rsa/ /etc/openvpn/client/easy-rsa
cd /etc/openvpn/client/easy-rsa/

\rm 3 3.0 
cd 3.0.3/

find / -type f -name "vars.example" | xargs -i cp {} . && mv vars.example vars


#创建新的pki
./easyrsa init-pki 
./easyrsa gen-req c nopass  #客户证书名为大林，木有密码

#签约客户端证书
cd /etc/openvpn/easy-rsa/3.0.3/

./easyrsa import-req /etc/openvpn/client/easy-rsa/3.0.3/pki/reqs/c.req c
./easyrsa sign client c



#整理证书
mkdir /etc/openvpn/certs
cd /etc/openvpn/certs/

cp /etc/openvpn/easy-rsa/3.0.3/pki/dh.pem .
cp /etc/openvpn/easy-rsa/3.0.3/pki/ca.crt .
cp /etc/openvpn/easy-rsa/3.0.3/pki/issued/server.crt .
cp /etc/openvpn/easy-rsa/3.0.3/pki/private/server.key .

mv dh.pem dh2048.pem:


mkdir /etc/openvpn/client/c/
cd /etc/openvpn/client/c/

cp /etc/openvpn/easy-rsa/3.0.3/pki/ca.crt .
cp /etc/openvpn/easy-rsa/3.0.3/pki/issued/c.crt .
cp /etc/openvpn/client/easy-rsa/3.0.3/pki/private/c.key .
