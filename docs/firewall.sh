#!/bin/bash

#Sets a variable for running iptables
IPT="/sbin/iptables"

#Flush old rules, delete the firewall chain if it exists, and set everything to drop by default.
$IPT -F
$IPT -P INPUT DROP

# Non-routable subnets, block this traffic on internet interfaces.
iptables -N NON_ROUTABLE
iptables -A NON_ROUTABLE -s 192.168.0.0/24 -j DROP
iptables -A NON_ROUTABLE -s 10.0.0.0/8 -j DROP
iptables -A NON_ROUTABLE -s 172.16.0.0/12 -j DROP
iptables -A NON_ROUTABLE -s 192.0.0.0/16 -j DROP
iptables -A NON_ROUTABLE -s 169.254.0.0/16 -j DROP
iptables -A NON_ROUTABLE -s 127.0.0.0/8 -j DROP

#Allow existing traffic, and allow ourselves
$IPT -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A INPUT -m state --state NEW -i lo -d localhost -j ACCEPT

#Block non-routable addresses
$IPT -A INPUT -m state NEW -i eth0 -j NON_ROUTABLE

#sent incoming packets through non_routable series of rules first
iptables -m state --state NEW -i eth0 -d xxx.xxx.xxx.xxx -j NON_ROUTABLE

#Allow PING
$IPT -A INPUT -m state --state NEW -i eth0 -d xxx.xxx.xxx.xxx -p icmp --icmp-type echo-request -j ACCEPT

#Allow SSH
$IPT -A INPUT -m state --state NEW -i eth0 -p tcp --syn --dport ssh -j ACCEPT

#Allow DNS
$IPT -A INPUT -m state --state NEW -i eth0 -p tcp --dport 53 -j ACCEPT

#Steam and related games
$IPT -A INPUT -m state --state NEW -i eth0 -p udp --dport 27000:27020 -j ACCEPT
$IPT -A INPUT -m state --state NEW -i eth0 -p udp --dport 1200 -j ACCEPT
$IPT -A INPUT -m state --state NEW -i eth0 -p tcp --dport 27015 -j ACCEPT
$IPT -A INPUT -m state --state NEW -i eth0 -p tcp --dport 27020:27050 -j ACCEPT

#Quake3, Wolfenstein, Enemy Territory
$IPT -A INPUT -m state --state NEW -i eth0 -p udp --dport 27960 -j ACCEPT

#UT2004
#$IPT -A INPUT -m state --state NEW -i eth0 -p udp --dport 7777:7778 -j ACCEPT
#$IPT -A INPUT -m state --state NEW -i eth0 -p udp --dport 7787 -j ACCEPT
#$IPT -A INPUT -m state --state NEW -i eth0 -p tcp --dport 28902 -j ACCEPT
#$IPT -A INPUT -m state --state NEW -i eth0 -p udp --dport 8888 -j ACCEPT# THE END
# ==================================================================