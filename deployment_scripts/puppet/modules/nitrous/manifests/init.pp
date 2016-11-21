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

class nitrous {

  $hiera_values = hiera_hash('nitrous', {})
  $nitrous_config = $hiera_values['node_additional_config']
  $nodes_hash = parseyaml($nitrous_config)
  $nodes_array = pick($nodes_hash['nodes'], [])

  $authors = 'Dinesh Yadav(dy270k@att.com)'
  $plugin_version = $hiera_values['metadata']['plugin_version']

  $agent_conf = '/etc/puppet/puppet.conf'
  $env_conf = '/etc/rc.local'
  $libvirt_conf = '/etc/libvirt'
  $line = $hiera_values['puppet_master_entry']
  $proxy_line = $hiera_values['aic_env_proxy']
  $site_yaml = '/etc/hiera/plugins/site.yaml'

  $network_scheme = hiera_hash('network_scheme', {})
  $net_bridge = $hiera_values['selective_default_bridge']
  $endpoints = pick($network_scheme['endpoints'])
  $endpoints_keys = keys($endpoints)
  $node_nic = upcase($::macaddress_br_fw_admin)
  $bond_nic = upcase($::macaddress_bond0)

  $nitrous_node = find_node($nodes_array, $node_nic)
  $node_name = downcase($nitrous_node['name'])
  $kvm_hostname = "$node_name"
  $ops_vms_array = parseyaml($hiera_values["ops_server_config"])

  $initiator_config='/etc/iscsi/initiatorname.iscsi'
  $storage = $nitrous_node['storage']
  $luns = $storage['luns']
  $storage_type = $storage['initiator_name']
  $storage_array = pick($nodes_hash['storage'], [])
  $target_node = $storage_array['targets']
  $opsvm_pool_type = $hiera_values['selective_opsvm_pool']

  $kvm_hosts = opsvm_filter($ops_vms_array, $kvm_hostname, br-fw-admin, br-mgmt)
  $vlan_tag = split($stg_nm, '\.')
  $vlan_id = $::nitrous::vlan_tag[1]
  $nic_bond = pick($network_scheme['transformations'])
  $mgmt = $nic_bond[6]
  $mgmt_brg = pick($mgmt['bridge'])
  $mgmt_nm = pick($mgmt['name'])
  $stg = $nic_bond[7]
  $stg_brg = pick($stg['bridge'])
  $stg_nm = pick($stg['name'])
  $prv = $nic_bond[8]
  $prv_brg = pick($prv['bridge'])
  $prv_nm = pick($prv['name'])

  if !($proxy_line == 'undef') {
    file_line { 'env_proxy':
      ensure  => 'present',
      line    => "export http_proxy=$:nitrous::proxy_line",
      path    => "$::nitrous::env_conf",
   }
  }

  exec { "src_bash":
    command => "bash -c 'source $env_conf'",
    path    => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin',
  }

  file_line { 'agent_conf' :
    ensure  => 'present',
    line    => "server = $line",
    path    => "$agent_conf",
    after   => 'pluginsync = True',
  }

  file { "$site_yaml":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0766',
    content => template('nitrous/nitrous.yaml.erb'),
  }

  if !($vlan_id == '') {
    file { '/usr/local/bin/rm_vlan.sh':
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0766',
      content => template('nitrous/vlan.erb'),
    }
   exec { 'remove_vlan':
     command => '/usr/local/bin/rm_vlan.sh',
     path    => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin',
   } 
   exec { 'add_brg':
     command => "brctl addif br-mgmt bond0",
     path    => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin',
   } 
  }

  file { '/usr/bin/opsvm':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0766',
    content => template('nitrous/opsvm.erb'),
  }

  anchor {'nitrous_begin' : } ->
  Class['nitrous::packages'] ->
  Class['nitrous::config'] ->
  anchor {'nitrous_end' : }

 }
