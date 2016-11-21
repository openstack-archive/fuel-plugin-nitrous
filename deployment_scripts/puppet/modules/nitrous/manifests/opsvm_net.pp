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

define nitrous::opsvm_net (
  $bridge,
  $forward_mode     = 'bridge',
  $virtualport_type = undef,
  $portgroups       = [],
  $autostart        = true,
 ) {
  exec {"opsvm-network-${name}":
    command  => join(['f=$(mktemp) && echo "',
                      template('nitrous/netbr.erb'),
                      '" > $f && virsh net-define $f && rm $f']),
    provider => 'shell',
    creates  => "${nitrous::libvirt_conf}/qemu/networks/${name}.xml",
  }

  if ($autostart) {
    exec {"opsvm-network-autostart-${name}":
      command => "virsh net-autostart ${name}",
      provider => 'shell',
      creates => "${nitrous::libvirt_conf}/qemu/networks/autostart/${name}.xml",
      require => Exec["opsvm-network-${name}"],
   }

  exec {"opsvm-network-start-${name}":
    command => "virsh net-start ${name}",
    provider => 'shell',
    unless  => "virsh net-list | tail -n +3 | cut -d ' ' -f 2 | \
                 grep -q ^${name}$",
    require => Exec["opsvm-network-${name}"],
  }
 }
}
