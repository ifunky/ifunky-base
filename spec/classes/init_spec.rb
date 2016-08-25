require 'spec_helper'

describe 'base', :type => :class do
  let(:facts) { {
      :osfamily  => 'Windows'
  } }

  context 'with defaults for all parameters' do
    it { should contain_class('base') }
  end

end