node.default['environment']['lan_subnet'] = "192.168.62.0/23"
node.default['environment']['lan_vip_gateway'] = "192.168.62.240"
node.default['environment']['lan_vip_nameserver'] = "192.168.62.240"
node.default['environment']['lan_subnet_dhcp'] = "192.168.62.32/27"
node.default['environment']['lan_if'] = "brlan"
node.default['environment']['lan_vrrp_state'] = "MASTER"
node.default['environment']['lan_vrrp_id'] = 20
node.default['environment']['lan_vrrp_priority'] = 200

node.default['environment']['vpn_subnet'] = "192.168.30.0/23"
node.default['environment']['vpn_subnet_dhcp'] = "192.168.30.32/27"
node.default['environment']['vpn_if'] = "brvpn"

node.default['environment']['wan_if'] = "eth1"
