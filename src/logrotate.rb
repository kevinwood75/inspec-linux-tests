control "libstdc-1.0" do
  impact 1.0
  title 'libstdc'
  desc "Validate libstdc installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat'
  end

  describe package('logrotate') do
    it { should be_installed }
  end

  describe service('crond') do
  	it { should be_running }
  end

  describe file('/etc/logrotate.conf') do
    it { should exist }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
  end
end