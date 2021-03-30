# == Class: nova::compute::libvirt::virtproxyd::config
#
# This class is used to manage arbitrary virtproxyd configurations.
#
# === Parameters
#
# [*virtproxyd_config*]
#   (optional) Allow configuration of arbitrary virtproxyd configurations.
#   The value is an hash of virtproxyd_config resources. Example:
#   { 'foo' => { value => 'fooValue'},
#     'bar' => { value => 'barValue'}
#   }
#   In yaml format, Example:
#   virtproxyd_config:
#     foo:
#       value: fooValue
#     bar:
#       value: barValue
#
#   NOTE: The configuration MUST NOT be already handled by this module
#   or Puppet catalog compilation will fail with duplicate resources.
#
class nova::compute::libvirt::virtproxyd::config (
  $virtproxyd_config        = {},
) {

  validate_legacy(Hash, 'validate_hash', $virtproxyd_config)

  create_resources('virtproxyd_config', $virtproxyd_config)
}

