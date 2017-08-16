dbag = Dbag::Keystore.new('deploy_config', 'rndc_keys')

node.default['kubelet']['ddns']['config'] = {
  "DhcpDdns" => {
    "ip-address" => "127.0.0.1",
    "port" => 53001,
    "dns-server-timeout" => 100,
    "ncr-protocol" => "UDP",
    "ncr-format" => "JSON",
    "tsig-keys" => [
      {
        "name" => "update_key",
        "algorithm" => "HMAC-SHA512",
        "secret" => dbag.get_or_create('update_key', SecureRandom.base64)
      }
    ],
    "forward-ddns" => {
      "ddns-domains" => [
        {
          "name" => "h.lan.",
          "key-name" => "update_key",
          "dns-servers" => [
            {
              "ip-address" => node['environment_v2']['set']['dns']['vip_lan'],
              "port" => 53530
            }
          ]
        }
      ]
    },
    "reverse-ddns" => {
      "ddns-domains" => [ ]
    }
  }
}
