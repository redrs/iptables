#!/bin/sh
#
# limit dns users/servers with iptables
IPTABLES=/sbin/iptables

# your ip
SERVER_OUT_IP="1.1.1.1"

# open dns servers
DNSSERVER="208.67.222.222 208.67.220.220"
DNSUSERS="root postfix ntp user"

# DNS outgoing set users
for dnsip in $DNSSERVER
do
  for dnsuser in $DNSUSERS
  do
   $IPTABLES -A OUTPUT -p udp -m udp -d $dnsip --dport 53 --sport 1024:65535 -s $SERVER_OUT_IP \
   -m conntrack --ctstate NEW --match owner --uid-owner $dnsuser -j ACCEPT \
   -m comment --comment "DNS out $dnsuser "
  done
done

# deny all other users DNS
$IPTABLES -A OUTPUT -p udp -m udp --dport 53 -j LOG --log-prefix "NO DNS for user " --log-uid
$IPTABLES -A OUTPUT -p tcp -m tcp --dport 53 -j LOG --log-prefix "NO DNS for user " --log-uid
$IPTABLES -A OUTPUT -p udp -m udp --dport 53 -j DROP
$IPTABLES -A OUTPUT -p tcp -m tcp --dport 53 -j DROP