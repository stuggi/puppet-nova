Puppet::Type.type(:virtnodedevd_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:ini_setting).provider(:ruby)
) do

  def section
    ''
  end

  def setting
    resource[:name]
  end

  def separator
    '='
  end

  def self.file_path
    '/etc/libvirt/virtnodedevd.conf'
  end

end

