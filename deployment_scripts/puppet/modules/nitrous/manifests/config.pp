# Copyright (c) 2016 AT&T Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

class nitrous::config {
 
  $ops_hosts = $::nitrous::kvm_hosts
  $ops_endpoints_keys = $::nitrous::endpoints_keys
  $pool_type = $::nitrous::opsvm_pool_type

  file { 'opsvms_settings' :
    ensure  => 'present',
    path    => '/etc/hiera/plugins/fuel_opsvms.yaml',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => inline_template('<%= require "yaml"; YAML.dump(@ops_hosts) + "\n" %>'),
  }

  file_line { 'kvm_user':
    path  => '/etc/libvirt/qemu.conf',
    line  => 'user = "root"',
    match => '#user = "root"',
  } ~>

  service {'libvirtd':
    ensure => 'running',
  }

  opsvm_pool { 'default' :
    ensure => present,
    type   => "$pool_type",
    active => true,
    target => '/opt/opsvm',
  }

  if !($::nitrous::node_name == '') {
    exec { "/bin/hostname $::nitrous::node_name" :
      path => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin',
    }
  } else {
      warning('Node is not available, please check Nitrous config.')
    }

  puppet::ops_endpoints_keys::keys { $ops_endpoints_keys: }
  define puppet::ops_endpoints_keys::keys ($ops_endpoints_keys = $title) {
    if ($::nitrous::net_bridge == 'linuxbr') {
      opsvm_net { "$ops_endpoints_keys" :
        forward_mode => 'bridge',
        bridge       => "$ops_endpoints_keys",
        autostart    => true,
      } 
    }
  } 
}
