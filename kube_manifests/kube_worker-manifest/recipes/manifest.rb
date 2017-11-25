master_hosts = node['environment_v2']['set']['kube-master']['hosts']

flannel_manifest = {
  "kind" => "Pod",
  "apiVersion" => "v1",
  "metadata" => {
    "name" => "kube-flannel-ds",
    "namespace" => "kube-system",
  },
  "spec" => {
    "hostNetwork" => true,
    "containers" => [
      {
        "name" => "kube-flannel",
        "image" => node['kube']['images']['flannel'],
        "command" => [
          "/opt/bin/flanneld",
          "--ip-masq",
          "--kube-subnet-mgr",
          "--kubeconfig-file=#{node['kubernetes']['client']['kubeconfig_path']}"
        ],
        "securityContext" => {
          "privileged" => true
        },
        "env" => [
          {
            "name" => "POD_NAME",
            "valueFrom" => {
              "fieldRef" => {
                "fieldPath" => "metadata.name"
              }
            }
          },
          {
            "name" => "POD_NAMESPACE",
            "valueFrom" => {
              "fieldRef" => {
                "fieldPath" => "metadata.namespace"
              }
            }
          }
        ],
        "volumeMounts" => [
          {
            "name" => "run",
            "mountPath" => "/run"
          },
          {
            "name" => "flannel-cfg",
            "mountPath" => "/etc/kube-flannel/"
          },
          {
            "name" => "kubeconfig",
            "mountPath" => node['kubernetes']['client']['kubeconfig_path'],
            "readOnly" => true
          },
          {
            "mountPath": "/etc/ssl",
            "name": "ssl-certs-host",
            "readOnly": true
          }
        ]
      }
    ],
    "volumes" => [
      {
        "name" => "run",
        "hostPath" => {
          "path" => "/run"
        }
      },
      {
        "name" => "flannel-cfg",
        "hostPath" => {
          "path" => "/etc/kube-flannel"
        }
      },
      {
        "name" => "kubeconfig",
        "hostPath" => {
          "path" => node['kubernetes']['client']['kubeconfig_path']
        }
      },
      {
        "name" => "ssl-certs-host",
        "hostPath" => {
          "path" => "/etc/ssl"
        }
      }
    ]
  }
}


kube_proxy_manifest = {
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {
    "name": "kube-proxy",
    "namespace": "kube-system"
  },
  "spec": {
    "hostNetwork": true,
    "containers": [
      {
        "name": "kube-proxy",
        "image": node['kube']['images']['hyperkube'],
        "command": [
          "/hyperkube",
          "proxy",
          "--kubeconfig=#{node['kubernetes']['client']['kubeconfig_path']}"
        ],
        "securityContext": {
          "privileged": true
        },
        "volumeMounts": [
          {
            "name" => "kubeconfig",
            "mountPath" => node['kubernetes']['client']['kubeconfig_path'],
            "readOnly" => true
          },
          {
            "mountPath": "/etc/ssl",
            "name": "ssl-certs-host",
            "readOnly": true
          }
        ]
      }
    ],
    "volumes": [
      {
        "name" => "kubeconfig",
        "hostPath" => {
          "path" => node['kubernetes']['client']['kubeconfig_path']
        }
      },
      {
        "name" => "ssl-certs-host",
        "hostPath" => {
          "path" => "/etc/ssl"
        }
      }
    ]
  }
}

node['environment_v2']['set']['kube-worker']['hosts'].each do |host|
  node.default['kubernetes']['static_pods'][host]['flannel.yaml'] = flannel_manifest
  node.default['kubernetes']['static_pods'][host]['kube-proxy_manifest.yaml'] = kube_proxy_manifest
end
