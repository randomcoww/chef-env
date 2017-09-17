node['qemu']['gateway']['hosts'].each do |host, config|

  host_config = node['environment_v2']['host'][host]

  mac_wan = host_config['mac_wan']
  memory = host_config['memory']
  vcpu = host_config['vcpu']
  image_path = "#{::File.join(node['qemu']['image_path'], host)}.qcow2"
  ignition_path = "#{::File.join(node['qemu']['ignition_path'], host)}.ign"

  networks = [
    {
      "#attributes"=>{
        "type"=>"network"
      },
      "source"=>{
        "#attributes"=>{
          "network"=>node['qemu']['libvirt_network_lan']
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
      "source"=>{
        "#attributes"=>{
          "network"=>node['qemu']['libvirt_network_wan']
        }
      },
      "mac"=>{
        "#attributes"=>{
          "address"=>mac_wan
        }
      },
      "model"=>{
        "#attributes"=>{
          "type"=>"virtio-net"
        }
      }
    }
  ]


  node.default['qemu']['configs'][host] = LibvirtConfig::ConfigGenerator.generate_from_hash({
    "domain"=>{
      "#attributes"=>{
        "type"=>"kvm",
        "xmlns:qemu"=>"http://libvirt.org/schemas/domain/qemu/1.0"
      },
      "name"=>host,
      "memory"=>{
        "#attributes"=>{
          "unit"=>"MiB"
        },
        "#text"=>memory
      },
      "currentMemory"=>{
        "#attributes"=>{
          "unit"=>"MiB"
        },
        "#text"=>memory
      },
      "vcpu"=>{
        "#attributes"=>{
          "placement"=>"static"
        },
        "#text"=>vcpu
      },
      "iothreads"=>"1",
      "iothreadids"=>{
        "iothread"=>{
          "#attributes"=>{
            "id"=>"1"
          }
        }
      },
      "sysinfo"=>{
        "#attributes"=>{
          "type"=>"smbios"
        },
        "baseBoard"=>{
          "entry"=>{
            "#attributes"=>{
              "name"=>"serial"
            },
            "#text"=>"ds=nocloud"
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
        },
        "smbios"=>{
          "#attributes"=>{
            "mode"=>"sysinfo"
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
            "cores"=>vcpu,
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
              "file"=>image_path
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
        "interface"=>networks,
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
      },
      "qemu:commandline"=>{
        "qemu:arg"=>[
          {
            "#attributes"=>{
              "value"=>"-fw_cfg"
            }
          },
          {
            "#attributes"=>{
              "value"=>"name=opt/com.coreos/config,file=#{ignition_path}"
            }
          }
        ]
      }
    }
  })

end
