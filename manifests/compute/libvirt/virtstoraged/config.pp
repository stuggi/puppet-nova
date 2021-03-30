# == Class: nova::compute::libvirt::virtstoraged::config
#
# This class is used to manage arbitrary virtstoraged configurations.
#
# === Parameters
#
# [*virtstoraged_config*]
#   (optional) Allow configuration of arbitrary virtstoraged configurations.
#   The value is an hash of virtstoraged_config resources. Example:
#   { 'foo' => { value => 'fooValue'},
#     'bar' => { value => 'barValue'}
#   }
#   In yaml format, Example:
#   virtstoraged_config:
#     foo:
#       value: fooValue
#     bar:
#       value: barValue
#
#   NOTE: The configuration MUST NOT be already handled by this module
#   or Puppet catalog compilation will fail with duplicate resources.
#
class nova::compute::libvirt::virtstoraged::config (
  $virtstoraged_config        = {},
) {

  validate_legacy(Hash, 'validate_hash', $virtstoraged_config)

  create_resources('virtstoraged_config', $virtstoraged_config)
}

