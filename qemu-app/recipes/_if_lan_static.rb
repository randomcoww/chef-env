current_host = node['qemu']['current_config']['hostname']
interface = node['environment_v2']['host'][current_host]['if_lan']

node.default['qemu']['current_config']['networking'][interface] = {
  "Match" => {
    "Name" => interface
  },
  "Network" => {
    "LinkLocalAddressing" => "no",
    "DHCP" => "no",
    "DNS" => (node['environment_v2']['set']['dns']['hosts'].map { |host|
      node['environment_v2']['host'][host]['ip_lan']
    } + [ '8.8.8.8' ])
  },
  "Address" => {
    "Address" => "#{node['environment_v2']['host'][current_host]['ip_lan']}/#{node['environment_v2']['subnet']['lan'].split('/').last}"
  },
  "Route" => {
    "Gateway" => node['environment_v2']['set']['gateway']['vip_lan'],
    "Metric" => 2048
  }
}

node.default['qemu']['current_config']['libvirt_networks'][interface] = {
  "#attributes"=>{
    "type"=>"direct",
    "trustGuestRxFilters"=>"yes"
  },
  "source"=>{
    "#attributes"=>{
      "dev"=>node['environment_v2']['current_host']['if_lan'],
      "mode"=>"bridge"
    }
  },
  "model"=>{
    "#attributes"=>{
      "type"=>"virtio-net"
    }
  }
}