#!/bin/bash
#
# From https://gist.github.com/Lewiscowles1986/fecd4de0b45b2029c390, https://andrewwippler.com/2016/03/11/wifi-captive-portal/ and other places

if [ "$EUID" -ne 0 ]
	then echo "Must be root"
	exit
fi

# echo "----------------------Updating repositories----------------------"
# apt-get update -yqq

# echo "----------------------Upgrading packages, this might take a while----------------------"
# apt-get upgrade -yqq

echo "----------------------Installing iptables-persistent"
apt-get install iptables-persistent -yqq

echo "----------------------Installing conntrack"
apt-get install conntrack -yqq

echo "----------------------Installing dnsmasq"
apt-get install dnsmasq -yqq

echo "----------------------Installing nginx"
apt-get install nginx -yqq

echo "----------------------Installing hostapd"
apt-get install hostapd -yqq

echo "----------------------Copying dnsmasq.conf"
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/dnsmasq.conf -O /etc/dnsmasq.conf

echo "----------------------Copying hosts"
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/hosts -O /etc/hosts

echo "----------------------Copying interfaces"
wget -q https://github.com/tretos53/Captive-Portal/blob/master/interfaces -O /etc/network/interfaces

echo "----------------------Copying hostapd.conf
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/hostapd.conf -O /etc/hostapd/hostapd.conf

echo "----------------------Configuring DAEMON
sed -i -- 's/#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/g' /etc/default/hostapd

echo "----------------------Configuring IP Tables

echo "----------------------Flushing all connections in the firewall
iptables -F

echo "----------------------Deleting all chains in iptables
iptables -X

echo "----------------------Setting up rules
iptables -t mangle -N wlan0_Trusted
iptables -t mangle -N wlan0_Outgoing
iptables -t mangle -N wlan0_Incoming
iptables -t mangle -I PREROUTING 1 -i wlan0 -j wlan0_Outgoing
iptables -t mangle -I PREROUTING 1 -i wlan0 -j wlan0_Trusted
iptables -t mangle -I POSTROUTING 1 -o wlan0 -j wlan0_Incoming
iptables -t nat -N wlan0_Outgoing
iptables -t nat -N wlan0_Router
iptables -t nat -N wlan0_Internet
iptables -t nat -N wlan0_Global
iptables -t nat -N wlan0_Unknown
iptables -t nat -N wlan0_AuthServers
iptables -t nat -N wlan0_temp
iptables -t nat -A PREROUTING -i wlan0 -j wlan0_Outgoing
iptables -t nat -A wlan0_Outgoing -d 192.168.24.1 -j wlan0_Router
iptables -t nat -A wlan0_Router -j ACCEPT
iptables -t nat -A wlan0_Outgoing -j wlan0_Internet
iptables -t nat -A wlan0_Internet -m mark --mark 0x2 -j ACCEPT
iptables -t nat -A wlan0_Internet -j wlan0_Unknown
iptables -t nat -A wlan0_Unknown -j wlan0_AuthServers
iptables -t nat -A wlan0_Unknown -j wlan0_Global
iptables -t nat -A wlan0_Unknown -j wlan0_temp

echo "----------------------Forwarding new requests to this destination
iptables -t nat -A wlan0_Unknown -p tcp --dport 80 -j DNAT --to-destination 192.168.24.1
iptables -t filter -N wlan0_Internet
iptables -t filter -N wlan0_AuthServers
iptables -t filter -N wlan0_Global
iptables -t filter -N wlan0_temp
iptables -t filter -N wlan0_Known
iptables -t filter -N wlan0_Unknown
iptables -t filter -I FORWARD -i wlan0 -j wlan0_Internet
iptables -t filter -A wlan0_Internet -m state --state INVALID -j DROP
iptables -t filter -A wlan0_Internet -o eth0 -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
iptables -t filter -A wlan0_Internet -j wlan0_AuthServers
iptables -t filter -A wlan0_AuthServers -d 192.168.24.1 -j ACCEPT
iptables -t filter -A wlan0_Internet -j wlan0_Global

echo "----------------------Allowing unrestricted access to packets marked with 0x2
iptables -t filter -A wlan0_Internet -m mark --mark 0x2 -j wlan0_Known
iptables -t filter -A wlan0_Known -d 0.0.0.0/0 -j ACCEPT
iptables -t filter -A wlan0_Internet -j wlan0_Unknown

echo "----------------------Allowing access to DNS and DHCP. This helps power users who have set their own DNS servers
iptables -t filter -A wlan0_Unknown -d 0.0.0.0/0 -p udp --dport 53 -j ACCEPT
iptables -t filter -A wlan0_Unknown -d 0.0.0.0/0 -p tcp --dport 53 -j ACCEPT
iptables -t filter -A wlan0_Unknown -d 0.0.0.0/0 -p udp --dport 67 -j ACCEPT
iptables -t filter -A wlan0_Unknown -d 0.0.0.0/0 -p tcp --dport 67 -j ACCEPT
iptables -t filter -A wlan0_Unknown -j REJECT --reject-with icmp-port-unreachable

echo "----------------------Saving iptables
iptables-save > /etc/iptables/rules.v4

echo "----------------------Making the HTML Document Root
mkdir /usr/share/nginx/html/portal
chown nginx:www-data /usr/share/nginx/html/portal
chmod 755 /usr/share/nginx/html/portal

echo "----------------------Copying hotspot.conf
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/nginx -O /etc/nginx/sites-available/hotspot.conf

echo "----------------------Copying index.html
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/index.html -O /usr/share/nginx/html/portal/index.html


echo "----------------------Enabling the website and reload nginx
ln -s /etc/nginx/sites-available/hotspot.conf /etc/nginx/sites-enabled/hotspot.conf
systemctl reload nginx

echo "----------------------Done, connect to the wifi and test.
