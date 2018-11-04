control "sensu_dashboard-1.0" do
  impact 1.0
  title 'sensu_dashboard'
  desc "Validate sensu_dashboard installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'sensu_dashboard'
  end

  describe package('sensu-enterprise-dashboard') do
    it { should be_installed }
  end
  
  describe service('sensu-enterprise-dashboard') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/etc/sensu/dashboard.json') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0640' }
    its('owner') { should eq 'sensu' }
    its('group') { should eq 'sensu' }
  end

  describe port(3000) do
    it { should be_listening }
  end
end
