require 'rails_helper'

describe Organization, type: :model do
  before :each do
    Organization.lookup_initials = ''
  end

  it 'should load correct values for SMC' do
    org = Organization.find_information_for_domain('test.host')
    Organization.lookup_initials = org['initials']
    expect(Organization.t('test', yes: 'yo')).to eq('I am San Mateo County, yo')
  end

  it 'should load correct values for SJ' do
    org = Organization.find_information_for_domain('test-sj.host')
    Organization.lookup_initials = org['initials']
    expect(Organization.t('test', yes: 'yo')).to eq('I am San Jose, yo')
  end
end
