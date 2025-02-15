require 'spec_helper'

describe 'nova::workarounds' do

  let :params do
    {}
  end

  shared_examples 'nova::workarounds' do

    context 'with default parameters' do
      it { is_expected.not_to contain_nova_config('workarounds/enable_numa_live_migration') }
      it { is_expected.to contain_nova_config('workarounds/never_download_image_if_on_rbd').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_nova_config('workarounds/ensure_libvirt_rbd_instance_dir_cleanup').with_value('<SERVICE DEFAULT>') }
    end

    context 'with overridden parameters' do
      let :params do
        {
          :enable_numa_live_migration => true,
          :never_download_image_if_on_rbd => true,
          :ensure_libvirt_rbd_instance_dir_cleanup => true
        }
      end

      it { is_expected.to contain_nova_config('workarounds/enable_numa_live_migration').with_value('true') }
      it { is_expected.to contain_nova_config('workarounds/never_download_image_if_on_rbd').with_value('true') }
      it { is_expected.to contain_nova_config('workarounds/ensure_libvirt_rbd_instance_dir_cleanup').with_value('true') }
    end

  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_configures 'nova::workarounds'
    end
  end
end
