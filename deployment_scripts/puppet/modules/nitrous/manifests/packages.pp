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

class nitrous::packages {
 
# Resources defaults

  $required_pkgs = ['qemu-kvm', 'libvirt-bin', 'db-util', 'db5.3-util', 'debhelper', 'dh-apparmor', 'gettext', 'ieee-data', 'intltool-debian', 'libcroco3', 'libunistring0', 'open-iscsi', 'po-debconf', 'python-crypto', 'python-ecdsa', 'python-libvirt', 'python-markupsafe', 'python-netaddr', 'python-netifaces', 'python-paramiko', 'qemu-utils', 'sasl2-bin', 'libasprintf-dev', 'libgettextpo-dev', 'libmail-sendmail-perl', 'sharutils','virtinst', 'ebtables', 'dnsmasq', 'libpcre3', 'cloud-guest-utils', 'cloud-image-utils', 'cloud-utils', 'euca2ools', 'fabric', 'ipmitool', 'genisoimage', 'libattr1', 'libreadline6', 'libsqlite3-0','mime-support', 'module-assistant', 'openvswitch-datapath-source', 'python-ipaddr', 'python-lxml', 'python-mako','python-nose', 'python-oauth', 'python-oauthlib', 'python-pexpect', 'python-requestbuilder', 'python-requests-oauthlib', 'readline-common' ]

  package { $required_pkgs :
    ensure => installed 
  }
}
