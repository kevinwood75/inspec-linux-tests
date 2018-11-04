files = inspec.command('ls /etc/influxdb').stdout.split("\n")

control "sensu_server-1.0" do
  impact 1.0
  title 'sensu_server'
  desc "Validate sensu_server installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'sensu_server'
  end

  describe package('sensu-enterprise') do
    it { should be_installed }
  end
  
  describe service('sensu-enterprise') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/etc/sensu/conf.d/redis.json') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0640' }
    its('owner') { should eq 'sensu' }
    its('group') { should eq 'sensu' }
  end
  
  describe file('/etc/sensu/conf.d/api.json') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0640' }
    its('owner') { should eq 'sensu' }
    its('group') { should eq 'sensu' }
  end
  
  # Leaving sensu server pillar data out of testing at the moment as it cannot be tested yet.
  describe port(4567) do
    it { should be_listening }
  end
end
