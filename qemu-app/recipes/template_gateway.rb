# node.default['qemu']['current_config']['hostname'] = 'host'
node.default['qemu']['current_config']['cloud_config_path'] = "/data/cloud-init/#{node['qemu']['current_config']['hostname']}"

node.default['qemu']['current_config']['chef_interval'] = '60min'
node.default['qemu']['current_config']['chef_recipes'] = [
  "recipe[system_update::debian]",
  "recipe[nftables-app::gateway]",
  "recipe[kubelet-app::master_disable_iptables]",
  "recipe[gateway-pod]"
]

node.default['qemu']['current_config']['memory'] = 512
node.default['qemu']['current_config']['vcpu'] = 2

node.default['qemu']['current_config']['runcmd'] = []

include_recipe "qemu-app::_cloud_config_common"


node.default['qemu']['current_config']['systemd_config']['/etc/systemd/network/50-eth0.network'] = {
  "Match" => {
    "Name" => "eth0"
  },
  "Network" => {
    "LinkLocalAddressing" => "no",
    "DHCP" => "no"
  },
  "Address" => {
    "Address" => "#{node['environment_v2']['host'][node['qemu']['current_config']['hostname']]['ip_lan']}/#{node['environment_v2']['subnet']['lan'].split('/').last}"
  },
  "Route" => {
    "Gateway" => node['environment_v2']['set']['gateway']['vip_lan'],
    "Metric" => 2048
  }
}

node.default['qemu']['current_config']['systemd_config']['/etc/systemd/network/50-eth1.network'] = {
  "Match" => {
    "Name" => "eth1"
  },
  "Network" => {
    "LinkLocalAddressing" => "no",
    "DHCP" => "yes",
    "DNS" => [
      node['environment_v2']['set']['dns']['vip_lan'],
      "8.8.8.8"
    ]
  },
  "DHCP" => {
    "UseDNS" => "false",
    "UseNTP" => "false",
    "SendHostname" => "false",
    "UseHostname" => "false",
    "UseDomains" => "false",
    "UseTimezone" => "no",
    "RouteMetric" => 1024,
    # "IPMasquerade" => "yes",
    # "IPForward" => "ipv4"
  }
}

include_recipe "qemu-app::_systemd_chef-client"


node.default['qemu']['current_config']['libvirt_config'] = {
  "domain"=>{
    "#attributes"=>{
      "type"=>"kvm"
    },
    "name"=>node['qemu']['current_config']['hostname'],
    "memory"=>{
      "#attributes"=>{
        "unit"=>"MiB"
      },
      "#text"=>node['qemu']['current_config']['memory']
    },
    "currentMemory"=>{
      "#attributes"=>{
        "unit"=>"MiB"
      },
      "#text"=>node['qemu']['current_config']['memory']
    },
    "vcpu"=>{
      "#attributes"=>{
        "placement"=>"static"
      },
      "#text"=>node['qemu']['current_config']['vcpu']
    },
    "iothreads"=>"1",
    "iothreadids"=>{
      "iothread"=>{
        "#attributes"=>{
          "id"=>"1"
        }
      }
    },
    "os"=>{
      "type"=>{
        "#attributes"=>{
          "arch"=>"x86_64",
          "machine"=>"pc"
        },
        "#text"=>"hvm"
      },
      "boot"=>{
        "#attributes"=>{
          "dev"=>"hd"
        }
      }
    },
    "features"=>{
      "acpi"=>"",
      "apic"=>"",
      "pae"=>""
    },
    "cpu"=>{
      "#attributes"=>{
        "mode"=>"host-passthrough"
      },
      "topology"=>{
        "#attributes"=>{
          "sockets"=>"1",
          "cores"=>node['qemu']['current_config']['vcpu'],
          "threads"=>"1"
        }
      }
    },
    "clock"=>{
      "#attributes"=>{
        "offset"=>"utc"
      }
    },
    "on_poweroff"=>"destroy",
    "on_reboot"=>"restart",
    "on_crash"=>"restart",
    "devices"=>{
      "emulator"=>"/usr/bin/qemu-system-x86_64",
      "disk"=>{
        "#attributes"=>{
          "type"=>"file",
          "device"=>"disk"
        },
        "driver"=>{
          "#attributes"=>{
            "name"=>"qemu",
            "type"=>"qcow2",
            "iothread"=>"1"
          }
        },
        "source"=>{
          "#attributes"=>{
            "file"=>"/data/kvm/#{node['qemu']['current_config']['hostname']}.qcow2"
          }
        },
        "target"=>{
          "#attributes"=>{
            "dev"=>"vda",
            "bus"=>"virtio"
          }
        }
      },
      "controller"=>[
        {
          "#attributes"=>{
            "type"=>"usb",
            "index"=>"0",
            "model"=>"none"
          }
        },
        {
          "#attributes"=>{
            "type"=>"pci",
            "index"=>"0",
            "model"=>"pci-root"
          }
        }
      ],
      "filesystem"=>[
        {
          "#attributes"=>{
            "type"=>"mount",
            "accessmode"=>"squash"
          },
          "source"=>{
            "#attributes"=>{
              "dir"=>"/data/secret/chef"
            }
          },
          "target"=>{
            "#attributes"=>{
              "dir"=>"chef-secret"
            }
          },
          "readonly"=>""
        },
        {
          "#attributes"=>{
            "type"=>"mount",
            "accessmode"=>"squash"
          },
          "source"=>{
            "#attributes"=>{
              "dir"=>node['qemu']['current_config']['cloud_config_path']
            }
          },
          "target"=>{
            "#attributes"=>{
              "dir"=>"cloud-init"
            }
          },
          "readonly"=>""
        }
      ],
      "interface"=>[
        {
          "#attributes"=>{
            "type"=>"network"
          },
          "source"=>{
            "#attributes"=>{
              "network"=>"passthrough_lan"
            }
          },
          "model"=>{
            "#attributes"=>{
              "type"=>"virtio-net"
            }
          }
        },
        {
          "#attributes"=>{
            "type"=>"network"
          },
          "mac"=>{
            "#attributes"=>{
              "address"=>node['environment_v2']['host'][node['qemu']['current_config']['hostname']]['mac_wan']
            }
          },
          "source"=>{
            "#attributes"=>{
              "network"=>"passthrough_wan"
            }
          },
          "model"=>{
            "#attributes"=>{
              "type"=>"virtio-net"
            }
          }
        }
      ],
      "serial"=>{
        "#attributes"=>{
          "type"=>"pty"
        },
        "target"=>{
          "#attributes"=>{
            "port"=>"0"
          }
        }
      },
      "console"=>{
        "#attributes"=>{
          "type"=>"pty"
        },
        "target"=>{
          "#attributes"=>{
            "type"=>"serial",
            "port"=>"0"
          }
        }
      },
      "input"=>[
        {
          "#attributes"=>{
            "type"=>"mouse",
            "bus"=>"ps2"
          }
        },
        {
          "#attributes"=>{
            "type"=>"keyboard",
            "bus"=>"ps2"
          }
        }
      ],
      "memballoon"=>{
        "#attributes"=>{
          "model"=>"virtio"
        }
      }
    }
  }
}

include_recipe "qemu-app::_deploy_common"
