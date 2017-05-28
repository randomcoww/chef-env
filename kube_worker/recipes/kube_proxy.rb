directory ::File.dirname(node['kube_worker']['kube_proxy']['kubeconfig_path']) do
  recursive true
  action [:create]
end

file node['kube_worker']['kube_proxy']['kubeconfig_path'] do
  content node['kube_worker']['kube_proxy']['kubeconfig'].to_hash.to_yaml
  action :create
end

systemd_unit 'kube-proxy.service' do
  content node['kube_worker']['kube_proxy']['systemd']
  action [:create, :enable, :start]
end