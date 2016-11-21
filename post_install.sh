#!/bin/bash
#
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

DEBUG=true
REL_NAME='Ubuntu 14.04'

FUEL='/usr/bin/fuel'
REL=`$FUEL rel | grep -i "${REL_NAME}.* available " | awk '{print $1}'`
FUEL_REL=`$FUEL rel | grep -i "${REL_NAME}.* available " | awk '{print $NF}'`

function debug {
  if $DEBUG; then
    echo $@
  fi
}

function set_min_controller_count {
  count=$1
  workdir=$(mktemp -d /tmp/modifyenv.XXXX)
  local os_roles=(ceph-osd cinder compute controller cinder-block-device ironic mongo)
  for role in ${os_roles[@]}; do
    $FUEL role --rel $REL --role $role --file $workdir/${role}.yaml
    sed -i "s/    min: ./    min: ${count}/" $workdir/${role}.yaml
    $FUEL role --rel $REL --update --file $workdir/${role}.yaml
  done
  rm -rf $workdir
}

set_min_controller_count 0
$FUEL rel --sync-deployment-tasks --dir /etc/puppet/$FUEL_REL
