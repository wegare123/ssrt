#!/bin/bash
#ssrt (Wegare)
stop () {
host="$(cat /root/akun/ssrt.txt | grep -i host | cut -d= -f2 | head -n1)" 
route="$(cat /root/akun/ipmodem.txt | grep -i ipmodem | cut -d= -f2 | tail -n1)" 
killall -q badvpn-tun2socks ssr-local ping-ssrt fping
route del 8.8.8.8 gw "$route" metric 0 2>/dev/null
route del 8.8.4.4 gw "$route" metric 0 2>/dev/null
route del "$host" gw "$route" metric 0 2>/dev/null
ip link delete tun1 2>/dev/null
/etc/init.d/dnsmasq restart 2>/dev/null
}
udp2="$(cat /root/akun/ssrt.txt | grep -i udp | cut -d= -f2)" 
host2="$(cat /root/akun/ssrt.txt | grep -i host | cut -d= -f2 | head -n1)" 
port2="$(cat /root/akun/ssrt.txt | grep -i port | cut -d= -f2)" 
bug2="$(cat /root/akun/ssrt.txt | grep -i bug | cut -d= -f2)" 
pass2="$(cat /root/akun/ssrt.txt | grep -i pass | cut -d= -f2)" 
enc2="$(cat /root/akun/ssrt.txt | grep -i enc | cut -d= -f2)" 
obfs2="$(cat /root/akun/ssrt.txt | grep -i obfs | cut -d= -f2)" 
protocol2="$(cat /root/akun/ssrt.txt | grep -i protocol | cut -d= -f2)" 
clear
echo "Inject shadowsocksr by wegare"
echo "1. Sett Profile"
echo "2. Start Inject"
echo "3. Stop Inject"
echo "4. Enable auto booting & auto rekonek"
echo "5. Disable auto booting & auto rekonek"
echo "e. exit"
read -p "(default tools: 2) : " tools
[ -z "${tools}" ] && tools="2"
if [ "$tools" = "1" ]; then

echo "Masukkan host/ip" 
read -p "default host/ip: $host2 : " host
[ -z "${host}" ] && host="$host2"

echo "Masukkan port" 
read -p "default port: $port2 : " port
[ -z "${port}" ] && port="$port2"

echo "Masukkan pass" 
read -p "default pass: $pass2 : " pass
[ -z "${pass}" ] && pass="$pass2"

echo "Masukkan bug" 
read -p "default bug: $bug2 : " bug
[ -z "${bug}" ] && bug="$bug2"

read -p "ingin menggunakan port udpgw y/n " pilih
if [ "$pilih" = "y" ]; then
echo "Masukkan port udpgw" 
read -p "default udpgw: $udp2 : " udp
[ -z "${udp}" ] && udp="$udp2"
badvpn="--socks-server-addr 127.0.0.1:1080 --udpgw-remote-server-addr 127.0.0.1:$udp"
elif [ "$pilih" = "Y" ]; then
echo "Masukkan port udpgw" 
read -p "default udpgw: $udp2 : " udp
[ -z "${udp}" ] && udp="$udp2"
badvpn="--socks-server-addr 127.0.0.1:1080 --udpgw-remote-server-addr 127.0.0.1:$udp"
else
badvpn="--socks-server-addr 127.0.0.1:1080"
fi

echo "Masukkan encryption method" 
read -p "default encryption method: $enc2 : " enc
[ -z "${enc}" ] && enc="$enc2"

echo "Masukkan protocol" 
read -p "default protocol: $protocol2 : " protocol
[ -z "${protocol}" ] && protocol="$protocol2"

echo "Masukkan obfs" 
read -p "default obfs: $obfs2 : " obfs
[ -z "${obfs}" ] && obfs="$obfs2"

echo "host=$host
port=$port
enc=$enc
pass=$pass
bug=$bug
protocol=$protocol
obfs=$obfs
udp=$udp" > /root/akun/ssrt.txt
cat <<EOF> /root/akun/ssrt.json
{
    "server":"$host",
    "server_port":"$port",
    "local_address":"127.0.0.1",
    "local_port":1080,
    "password":"$pass",
    "timeout":120,
    "method":"$enc",
    "protocol":"$protocol",
    "protocol_param":"",
    "obfs":"$obfs",
    "obfs_param":"$bug",
    "redirect":"",
    "dns_ipv6":false,
    "fast_open":true,
    "workers":1
}
EOF
cat <<EOF> /usr/bin/gproxy-ssrt
badvpn-tun2socks --tundev tun1 --netif-ipaddr 10.0.0.2 --netif-netmask 255.255.255.0 $badvpn --udpgw-connection-buffer-size 65535 --udpgw-transparent-dns &
EOF
chmod +x /usr/bin/gproxy-ssrt

echo "Sett Profile Sukses"
sleep 2
clear
/usr/bin/ssrt
elif [ "${tools}" = "2" ]; then
stop
ipmodem="$(route -n | grep -i 0.0.0.0 | head -n1 | awk '{print $2}')" 
echo "ipmodem=$ipmodem" > /root/akun/ipmodem.txt
udp="$(cat /root/akun/ssrt.txt | grep -i udp | cut -d= -f2)" 
host="$(cat /root/akun/ssrt.txt | grep -i host | cut -d= -f2 | head -n1)" 
route="$(cat /root/akun/ipmodem.txt | grep -i ipmodem | cut -d= -f2 | tail -n1)" 

ssr-local -c /root/akun/ssrt.json &
sleep 3
ip tuntap add dev tun1 mode tun
ifconfig tun1 10.0.0.1 netmask 255.255.255.0
/usr/bin/gproxy-ssrt
route add 8.8.8.8 gw "$route" metric 0
route add 8.8.4.4 gw "$route" metric 0
route add "$host" gw "$route" metric 0
route add default gw 10.0.0.2 metric 0
echo '
#!/bin/bash
#ssrt (Wegare)
host="$(cat /root/akun/ssrt.txt | grep -i host | cut -d= -f2 | head -n1)"
fping -l $host' > /usr/bin/ping-ssrt
chmod +x /usr/bin/ping-ssrt
/usr/bin/ping-ssrt > /dev/null 2>&1 &
elif [ "${tools}" = "3" ]; then
stop
echo "Stop Suksess"
sleep 2
clear
/usr/bin/ssrt
elif [ "${tools}" = "4" ]; then
cat <<EOF>> /etc/crontabs/root

# BEGIN AUTOREKONEKSSRT
*/1 * * * *  autorekonek-ssrt
# END AUTOREKONEKSSRT
EOF
sed -i '/^$/d' /etc/crontabs/root 2>/dev/null
/etc/init.d/cron restart
echo "Enable Suksess"
sleep 2
clear
/usr/bin/ssrt
elif [ "${tools}" = "5" ]; then
sed -i "/^# BEGIN AUTOREKONEKSSRT/,/^# END AUTOREKONEKSSRT/d" /etc/crontabs/root > /dev/null
/etc/init.d/cron restart
echo "Disable Suksess"
sleep 2
clear
/usr/bin/ssrt
elif [ "${tools}" = "e" ]; then
clear
exit
else 
echo -e "$tools: invalid selection."
exit
fi