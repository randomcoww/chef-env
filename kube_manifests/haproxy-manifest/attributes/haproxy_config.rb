services = {}

lan_domain = [
  node['environment_v2']['domain']['host_lan'],
  node['environment_v2']['domain']['top']
].join('.')


node['environment_v2']['set'].each_value do |set|
  if set.is_a?(Hash) &&
    set.has_key?('services')

    set['services'].each do |service, c|
      if node['environment_v2']['haproxy'].has_key?(service) &&
        node['environment_v2']['haproxy'][service].has_key?('port')

        bind = node['environment_v2']['haproxy'][service]['port']

        services["frontend #{service}"] = {
          'default_backend' => service,
          'bind' => "*:#{bind}",
          'maxconn' => 2000
        }

        backend = []
        set['hosts'].each do |host|
          backend << "#{host} #{[host, lan_domain].join('.')}:#{c['port']} init-addr libc,none resolvers default"
        end

        services["backend #{service}"] = {
          "server" => backend
        }
      end
    end
  end
end


node.default['kube_manifests']['haproxy']['haproxy_config'] = HaproxyHelper::ConfigGenerator.generate_from_hash({
  'global' => {
    # 'user' => 'haproxy',
    # 'group' => 'haproxy',
    'log' => '127.0.0.1 local0',
    'log-tag' => 'haproxy',
    'daemon' => nil,
    'quiet' => nil,
    'stats' => [
      # 'socket /var/run/haproxy.sock user haproxy group haproxy',
      'socket /var/run/haproxy.sock',
      'timeout 2m'
    ],
    'maxconn' => 1024,
    'pidfile' => '/var/run/haproxy.pid'
  },
  'resolvers default' => {
    'nameserver' => node['environment_v2']['set']['ns']['hosts'].map { |e|
      "#{e} #{node['environment_v2']['host'][e]['ip_lan']}:53"
    },
    # 'nameserver' => "vip #{node['environment_v2']['set']['gateway']['vip_lan']}:53",
    'resolve_retries' => 3
  },
  'defaults' => {
    'timeout' => [
      'connect 5000ms',
      'client 10000ms',
      'server 10000ms'
    ],
    'log' => 'global',
    'mode' => 'tcp',
    'balance' => 'roundrobin',
    'option' => [
      'dontlognull',
      'redispatch'
    ],
    # 'stats' => 'uri /haproxy-status'
  }
}.merge(services))
