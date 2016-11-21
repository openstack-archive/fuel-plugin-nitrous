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

Puppet::Type.newtype(:opsvm_pool) do
@doc = %q{Manages opsvm pools

          Example : 
            opsvm_pool { 'default' : 
              ensure => absent
            }

            opsvm_pool { 'mydirpool' :
              ensure    => present,
              active    => true,
              autostart => true,
              type      => 'dir',
              target    => '/tmp/mypool',
            }

            opsvm_pool { 'vm_storage':
              ensure    => 'present',
              active    => 'true',
              type      => 'logical',
              sourcedev => ['/dev/sdb', '/dev/sdc'],
              target    => '/dev/vg0'
            }


        }

  ensurable do

    desc 'Creation or the removal of a pool`present` means that the pool will be defined and created
    `absent` means that the pool will be purged from the system'

    defaultto(:present)
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      if (provider.exists?)
        provider.destroy
      end
    end

    def retrieve
      provider.status
    end

  end

  newparam(:name, :namevar => true) do
    desc 'The pool name.'
    newvalues(/^\S+$/)
  end

  newparam(:type) do
    desc 'The pool type.'
    newvalues(:dir, :netfs, :fs, :logical, :disk, :iscsi, :mpath, :rbd, :sheepdog)
  end

  newparam(:sourcehost) do
    desc 'The source host.'   
    newvalues(/^\S+$/)
  end

  newparam(:sourcepath) do
    desc 'The source path.'
    newvalues(/(\/)?(\w)/)
  end

  newparam(:sourcedev) do
    desc 'The source device.'
    newvalues(/(\/)?(\w)/)
  end

  newparam(:sourcename) do
    desc 'The source name.'
    newvalues(/^\S+$/)
  end

  newparam(:sourceformat) do
    desc 'The source format.'
    newvalues(:auto, :nfs, :glusterfs, :cifs)
  end
  
  newparam(:target) do
    desc 'The target.'
    newvalues(/(\/)?(\w)/)
  end

  newproperty(:active) do
    desc 'Whether the pool should be started.'
    defaultto(:true)
    newvalues(:true)
    newvalues(:false)
  end

  newproperty(:autostart) do
    desc 'Whether the pool should be autostarted.'
    defaultto(:false)
    newvalues(:true)
    newvalues(:false)
  end

end
