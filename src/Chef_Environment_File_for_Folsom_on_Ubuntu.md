{
    "json_class": "Chef::Environment",
    "description": "",
    "override_attributes": {
      "mysql": {
        "root_network_acl": "%",
        "allow_remote_root": true,
        "server_debian_password": "password",
        "server_root_password": "password",
        "server_repl_password": "password",
        "tunable":{
           "character-set-server":"latin1",
           "collation-server":"latin1_swedish_ci"
        },   
        "db": {
          "bind_host": "0.0.0.0"
        }
      },
      "nova": {
        "network": {
          "floating": {
            "ipv4_cidr": "10.1.0.0/16"
          }
        },
        "libvirt": {
          "virt_type": "kvm"
        },
        "networks": [
          {
            "network_size": "325125",
            "dns1": "10.1.0.218",
            "ipv4_cidr": "10.1.0.0/16",
            "label": "vmnet",
            "bridge_dev": "eth0",
            "bridge": "br0",
            "num_networks": "1"
          }
        ],
        "db": {
          "password": "password",
          "name": "nova",
          "username": "nova"
        }
      },
      "developer_mode": false,
      "cinder": {
        "db": {
          "password": "password",
          "name": "cinder",
          "username": "cinder"
        }
      },
      "osops_networks": {
        "nova": "10.1.0.0/16",
        "management": "10.1.0.0/16",
        "public": "10.1.0.0/16"
      },
      "keystone": {
        "services": {
          "admin-api": {
            "host": "0.0.0.0"
          },
          "service-api": {
            "network": "nova"
          }
        },
        "bind_host": "0.0.0.0",
        "db": {
          "password": "password",
          "name": "keystone",
          "username": "keystone"
        }
      },
      "glance": {
        "image_upload": false,
        "images": [
          "cirros",
          "precise"
        ],
        "db": {
          "password": "password",
          "name": "glance",
          "username": "glance"
        },
        "image": {
          "precise": "http://10.1.0.82/images/precise-server-cloudimg-amd64-disk1.img",
          "cirros": "http://10.1.0.82/images/cirros-0.3.0-x86_64-uec.tar.gz"
        }
      },
      "db_type": "mysql"
    },
    "default_attributes": {
      "floating": "false",
      "package_component": "grizzly"
    },
    "cookbook_versions": {
    },
    "name": "nick",
    "chef_type": "environment"
    }
    
