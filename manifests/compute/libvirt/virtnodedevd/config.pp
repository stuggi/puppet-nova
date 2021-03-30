# == Class: nova::compute::libvirt::virtnodedevd::config
#
# This class is used to manage arbitrary virtnodedevd configurations.
#
# === Parameters
#
# [*virtnodedevd_config*]
#   (optional) Allow configuration of arbitrary virtnodedevd configurations.
#   The value is an hash of virtnodedevd_config resources. Example:
#   { 'foo' => { value => 'fooValue'},
#     'bar' => { value => 'barValue'}
#   }
#   In yaml format, Example:
#   virtnodedevd_config:
#     foo:
#       value: fooValue
#     bar:
#       value: barValue
#
#   NOTE: The configuration MUST NOT be already handled by this module
#   or Puppet catalog compilation will fail with duplicate resources.
#
class nova::compute::libvirt::virtnodedevd::config (
  $virtnodedevd_config        = {},
) {

  validate_legacy(Hash, 'validate_hash', $virtnodedevd_config)

  create_resources('virtnodedevd_config', $virtnodedevd_config)
}

