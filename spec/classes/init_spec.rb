require 'spec_helper'
describe 'observium' do

  context 'with default params on osfamily Debian' do
    let :facts do
      {
        :osfamily  => 'Debian',
      }
    end
    it { should include_class('observium')}

  end
end
