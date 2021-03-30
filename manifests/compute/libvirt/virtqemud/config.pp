# == Class: nova::compute::libvirt::virtqemud::config
#
# This class is used to manage arbitrary virtqemud configurations.
#
# === Parameters
#
# [*virtqemud_config*]
#   (optional) Allow configuration of arbitrary virtqemud configurations.
#   The value is an hash of virtqemud_config resources. Example:
#   { 'foo' => { value => 'fooValue'},
#     'bar' => { value => 'barValue'}
#   }
#   In yaml format, Example:
#   virtqemud_config:
#     foo:
#       value: fooValue
#     bar:
#       value: barValue
#
#   NOTE: The configuration MUST NOT be already handled by this module
#   or Puppet catalog compilation will fail with duplicate resources.
#
class nova::compute::libvirt::virtqemud::config (
  $virtqemud_config        = {},
) {

  validate_legacy(Hash, 'validate_hash', $virtqemud_config)

  create_resources('virtqemud_config', $virtqemud_config)
}

