#
# Copyright (C) 2014 OpenStack Foundation
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
#         Donald Talton  <dotalton@cisco.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

# == Class: nova::compute::rbd
#
# Configure nova-compute to store virtual machines on RBD
#
# === Parameters
#
# [*libvirt_images_rbd_pool*]
#   (optional) The RADOS pool in which rbd volumes are stored.
#   Defaults to 'rbd'.
#
# [*libvirt_images_rbd_ceph_conf*]
#   (optional) The path to the ceph configuration file to use.
#   Defaults to '/etc/ceph/ceph.conf'.
#
# [*libvirt_images_rbd_glance_store_name*]
#   (optional) Name of the Glance store that represents the local rbd cluster.
#   If set, this will allow Nova to request that Glance copy an image from
#   an existing non-local store into the one named by this option before
#   booting so that proper Copy-on-Write behavior is maintained.
#   Defaults to $::os_service_default.
#
# [*libvirt_images_rbd_glance_copy_poll_interval*]
#   (optional) The interval in seconds with which to poll Glance after asking
#   for it to copy an image to the local rbd store.
#   Defaults to $::os_service_default.
#
# [*libvirt_images_rbd_glance_copy_timeout*]
#   (optional) The overall maximum time we will wait for Glance to complete
#   an image copy to our local rbd store.
#   Defaults to $::os_service_default.
#
# [*libvirt_rbd_user*]
#   (Required) The RADOS client name for accessing rbd volumes.
#
# [*libvirt_rbd_secret_uuid*]
#   (optional) The libvirt uuid of the secret for the rbd_user.
#   Required to use cephx.
#   Default to false.
#
# [*libvirt_rbd_secret_key*]
#   (optional) The cephx key to use as key for the libvirt secret,
#   it must be base64 encoded; when not provided this key will be
#   requested to the ceph cluster, which assumes the node is
#   provided of the client.admin keyring as well.
#   Default to undef.
#
# [*rbd_keyring*]
#   (optional) The keyring name to use when retrieving the RBD secret
#   Default to 'client.nova'
#
# [*ephemeral_storage*]
#   (optional) Wether or not to use the rbd driver for the nova
#   ephemeral storage or for the cinder volumes only.
#   Defaults to true.
#
# [*manage_ceph_client*]
#  (optional) Whether to manage the ceph client package.
#  Defaults to true.
#
# [*ceph_client_ensure*]
#  (optional) Ensure value for ceph client package.
#  Defaults to 'present'.


class nova::compute::rbd (
  $libvirt_rbd_user,
  $libvirt_rbd_secret_uuid                      = false,
  $libvirt_rbd_secret_key                       = undef,
  $libvirt_images_rbd_pool                      = 'rbd',
  $libvirt_images_rbd_ceph_conf                 = '/etc/ceph/ceph.conf',
  $libvirt_images_rbd_glance_store_name         = $::os_service_default,
  $libvirt_images_rbd_glance_copy_poll_interval = $::os_service_default,
  $libvirt_images_rbd_glance_copy_timeout       = $::os_service_default,
  $rbd_keyring                                  = 'client.nova',
  $ephemeral_storage                            = true,
  $manage_ceph_client                           = true,
  $ceph_client_ensure                           = 'present',
) {

  include nova::deps
  include nova::params

  if $manage_ceph_client {
    # Install ceph client libraries
    package { 'ceph-client-package':
      ensure => $ceph_client_ensure,
      name   => $nova::params::ceph_client_package_name,
      tag    => ['openstack'],
    }
  }

  nova_config {
    'libvirt/rbd_user': value => $libvirt_rbd_user;
  }

  if $libvirt_rbd_secret_uuid {
    nova_config {
      'libvirt/rbd_secret_uuid': value => $libvirt_rbd_secret_uuid;
    }

    file { '/etc/nova/secret.xml':
      content => template('nova/secret.xml-compute.erb'),
      require => Anchor['nova::config::begin'],
    }

    #Variable name shrunk in favor of removing
    #the more than 140 chars puppet-lint warning.
    #variable used in the get-or-set virsh secret
    #resource.
    $cm = '/usr/bin/virsh secret-define --file /etc/nova/secret.xml | /usr/bin/awk \'{print $2}\' | sed \'/^$/d\' > /etc/nova/virsh.secret'
    exec { 'get-or-set virsh secret':
      command => $cm,
      unless  => "/usr/bin/virsh secret-list | grep -i ${libvirt_rbd_secret_uuid}",
      require => File['/etc/nova/secret.xml'],
    }
    Service<| title == 'libvirt' |> -> Exec['get-or-set virsh secret']

    if $libvirt_rbd_secret_key {
      $libvirt_key = $libvirt_rbd_secret_key
    } else {
      $libvirt_key = "$(ceph auth get-key ${rbd_keyring})"
    }
    exec { 'set-secret-value virsh':
      command => "/usr/bin/virsh secret-set-value --secret ${libvirt_rbd_secret_uuid} --base64 ${libvirt_key}",
      unless  => "/usr/bin/virsh secret-get-value ${libvirt_rbd_secret_uuid} | grep ${libvirt_key}",
      require => Exec['get-or-set virsh secret'],
    }
  }

  if $ephemeral_storage {

    #  TODO(tkajinam): Remove this implementation in X
    if defined('$::nova::compute::libvirt::images_type') {
      # When nova::compute::libvirt is evaluated before nova::compute::rbd, we
      # never set it here unless $::nova::compute::libvirt::images_type is
      # default, for backwards compatibility
      $images_type_real = $::nova::compute::libvirt::images_type
      if is_service_default($images_type_real) {
        warning('nova::compute::libvirt::images_type will be required if rbd ephemeral storage is used.')
        nova_config {
          'libvirt/images_type': value => 'rbd';
        }
      } elsif $images_type_real != 'rbd' {
        fail('nova::compute::libvirt::images_type should be rbd if rbd ephemeral storage is used.')
      }
    }
    else {
    # This is when only nova::compute::rbd is used,
    # or when nova::compute::rbd is evaluated before nova::compute::libvirt
      nova_config {
        'libvirt/images_type': value => 'rbd';
      }
    }

    nova_config {
      'libvirt/images_rbd_pool':                      value => $libvirt_images_rbd_pool;
      'libvirt/images_rbd_ceph_conf':                 value => $libvirt_images_rbd_ceph_conf;
      'libvirt/images_rbd_glance_store_name':         value => $libvirt_images_rbd_glance_store_name;
      'libvirt/images_rbd_glance_copy_poll_interval': value => $libvirt_images_rbd_glance_copy_poll_interval;
      'libvirt/images_rbd_glance_copy_timeout':       value => $libvirt_images_rbd_glance_copy_timeout;

    }
  } else {
    nova_config {
      'libvirt/images_rbd_pool':                      ensure => absent;
      'libvirt/images_rbd_ceph_conf':                 ensure => absent;
      'libvirt/images_rbd_glance_store_name':         ensure => absent;
      'libvirt/images_rbd_glance_copy_poll_interval': ensure => absent;
      'libvirt/images_rbd_glance_copy_timeout':       ensure => absent;
    }
  }

}
