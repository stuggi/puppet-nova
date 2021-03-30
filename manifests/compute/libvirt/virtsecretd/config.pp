# == Class: nova::compute::libvirt::virtsecretd::config
#
# This class is used to manage arbitrary virtsecretd configurations.
#
# === Parameters
#
# [*virtsecretd_config*]
#   (optional) Allow configuration of arbitrary virtsecretd configurations.
#   The value is an hash of virtsecretd_config resources. Example:
#   { 'foo' => { value => 'fooValue'},
#     'bar' => { value => 'barValue'}
#   }
#   In yaml format, Example:
#   virtsecretd_config:
#     foo:
#       value: fooValue
#     bar:
#       value: barValue
#
#   NOTE: The configuration MUST NOT be already handled by this module
#   or Puppet catalog compilation will fail with duplicate resources.
#
class nova::compute::libvirt::virtsecretd::config (
  $virtsecretd_config        = {},
) {

  validate_legacy(Hash, 'validate_hash', $virtsecretd_config)

  create_resources('virtsecretd_config', $virtsecretd_config)
}

