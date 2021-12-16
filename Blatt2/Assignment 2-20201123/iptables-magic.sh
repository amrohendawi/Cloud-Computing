#/bin/bash

floating_subnet="10.122.0.0/24"
floating_gateway="10.122.0.1"

ip a add $floating_gateway dev br-ex
ip link set br-ex up
ip link set dev br-ex mtu 1400  # Ensure correct ssh connection

ip r a "$floating_subnet" via $floating_gateway dev br-ex

# iptables -t nat -A POSTROUTING -o ens4 -j MASQUERADE

# iptables -A FORWARD -i ens4 -o br-ex -j ACCEPT
# iptables -A FORWARD -i br-ex -o ens4 -j ACCEPT

