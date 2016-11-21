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

module Puppet::Parser::Functions
  newfunction(:opsvm_filter, :type => :rvalue, :doc => <<-EOS
Filter the ops_server_config array and convert to the structure readable by the opsvm script.
  EOS
  ) do |args|
    ops_server_config = args[0]
    pxe_br = args[2]
    kvm_filter = args[1]
    mgt_br = args[3]
    fail "The ops_server_config should be an Array! Got: #{ops_server_config}" unless ops_server_config.is_a? Array
    kvm_hosts = []
    ops_server_config.each do |op_host|
      next unless op_host['kvm'] == kvm_filter

      host_hash = {}
      host_hash['name'] = op_host['name'] if op_host['name']
      host_hash['cpu'] = op_host.fetch('cpu', 2)
      host_hash['ram'] = op_host.fetch('ram', 2).to_i * 1024

      networks = []
      pxe_network = {}
      pxe_network['network'] = "#{pxe_br}"
      pxe_network['mac'] = op_host['mac_address']
      networks << pxe_network
      mgmt_network = {}
      mgmt_network['network'] = "#{mgt_br}"
      networks << mgmt_network

      host_hash['networks'] = networks

      volumes = []
      app_volume = {}
      app_volume['size'] = op_host.fetch('app_disk', 10).to_i * 1024 * 1024 * 1024
      app_volume['name'] = op_host['app_volume_name']
      app_volume['name'] = "app_disk_#{host_hash['name']}" unless app_volume['name']
      volumes << app_volume
      os_volume = {}
      os_volume['size'] = op_host.fetch('os_disk', 10).to_i * 1024 * 1024 * 1024
      os_volume['name'] = op_host['os_volume_name']
      os_volume['name'] = "os_disk_#{host_hash['name']}" unless os_volume['name']
      volumes << os_volume
      log_volume = {}
      log_volume['size'] = op_host.fetch('log_disk', 10).to_i * 1024 * 1024 * 1024
      log_volume['name'] = op_host['log_volume_name']
      log_volume['name'] = "log_disk_#{host_hash['name']}" unless log_volume['name']
      volumes << log_volume

      host_hash['volumes'] = volumes

      kvm_hosts << host_hash
    end
    kvm_hosts
  end
end
