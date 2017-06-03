node.default['kubernetes']['docker']['pkg_names'] = ['docker-engine']

node.default['kubernetes']['docker']['systemd_dropin'] = {
  'Unit' => {
    'After' => 'flannel.service',
    'Requires' => 'flannel.service',
    'ConditionFileNotEmpty' => node['kubernetes']['flannel']['environment']['FLANNELD_SUBNET_FILE']
  },
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "EnvironmentFile" => node['kubernetes']['flannel']['environment']['FLANNELD_SUBNET_FILE'],
    "ExecStart" => [
      '',
      "/usr/bin/dockerd -H fd:// --bip=${FLANNEL_SUBNET} --mtu=${FLANNEL_MTU} --log-driver=journald --ip-masq=false --iptables=false"
    ]
  }
}
