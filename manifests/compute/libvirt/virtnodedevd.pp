# == Class: nova::compute::libvirt::virtnodedevd
#
# virtnodedevd configuration
#
# === Parameters:
#
# [*log_level*]
#   Defines a log level to filter log outputs.
#   Defaults to undef
#
# [*log_filters*]
#   Defines a log filter to select a different logging level for
#   for a given category log outputs.
#   Defaults to undef
#
# [*log_outputs*]
#   (optional) Defines log outputs, as specified in
#   https://libvirt.org/logging.html
#   Defaults to undef
#
# [*max_clients*]
#   The maximum number of concurrent client connections to allow
#   on primary socket.
#   Defaults to undef
#
# [*admin_max_clients*]
#   The maximum number of concurrent client connections to allow
#   on administrative socket.
#   Defaults to undef
#
# [*ovs_timeout*]
#   (optional) A timeout for openvswitch calls made by libvirt
#   Defaults to undef
#
class nova::compute::libvirt::virtnodedevd (
  $log_level         = undef,
  $log_filters       = undef,
  $log_outputs       = undef,
  $max_clients       = undef,
  $admin_max_clients = undef,
  $ovs_timeout       = undef,
) {

  include nova::deps
  require nova::compute::libvirt

  if $log_level {
    virtnodedevd_config {
      'log_level': value => $log_level;
    }
  }
  else {
    virtnodedevd_config {
      'log_level': ensure => 'absent';
    }
  }

  if $log_filters {
    virtnodedevd_config {
      'log_filters': value => "\"${log_filters}\"";
    }
  }
  else {
    virtnodedevd_config {
      'log_filters': ensure => 'absent';
    }
  }

  if $log_outputs {
    virtnodedevd_config {
      'log_outputs': value => "\"${log_outputs}\"";
    }
  }
  else {
    virtnodedevd_config {
      'log_outputs': ensure => 'absent';
    }
  }

  if $max_clients {
    virtnodedevd_config {
      'max_clients': value => $max_clients;
    }
  }
  else {
    virtnodedevd_config {
      'max_clients': ensure => 'absent';
    }
  }

  if $admin_max_clients {
    virtnodedevd_config {
      'admin_max_clients': value => $admin_max_clients;
    }
  }
  else {
    virtnodedevd_config {
      'admin_max_clients': ensure => 'absent';
    }
  }

  if $ovs_timeout {
    virtnodedevd_config {
      'ovs_timeout': value => $ovs_timeout;
    }
  } else {
    virtnodedevd_config {
      'ovs_timeout': ensure => 'absent';
    }
  }

  Anchor['nova::config::begin']
  -> Virtnodedevd_config<||>
  -> Anchor['nova::config::end']
}
