require 'spec_helper'
describe 'observium' do

  context 'with default params on osfamily Debian' do
    let :facts do
      {
        :osfamily  => 'Debian',
      }
    end
    it { should include_class('observium')}

    it do
      should contain_package('observium_packages').with({
        'ensure' => 'installed',
        'name'   => 'observium',
      })
    end
    it do
      should contain_file('observium_config').with({
        'ensure'  => 'present',
        'path'    => '/opt/observium/config.php',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0755',
      })
    end
  end
end
