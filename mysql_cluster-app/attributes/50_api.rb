node.default['mysql_cluster']['api']['pkg_names'] = [
  'mysql-cluster-community-server'
]

node.default['mysql_cluster']['api']['config'] = {
  'mysqld' => {
    'ndbcluster' => nil,
    'default_storage_engine' => 'ndbcluster',
    'ndb-connectstring' => [
      node['environment_v2']['host']['kea-mysql-mgmd']['ip_lan']
    ].join(','),
    'bind-address' => '0.0.0.0'
  }
}
