#!/bin/bash

echo "option domain_name, host_name" > /etc/dhcpcd.conf
echo 'nameserver 127.0.0.1' | sudo tee /etc/resolv.conf > /dev/null
setcap 'cap_net_bind_service=+ep' /usr/bin
hnsd "$@"
