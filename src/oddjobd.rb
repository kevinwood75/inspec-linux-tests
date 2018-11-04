control "oddjobd-1.0" do
  impact 1.0
  title 'oddjobd'
  desc "Validate oddjobd installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and (grains['active_directory_joined'] == 'True' || grains['active_directory_joined'] == true)
  end

  describe package('oddjob') do
    it { should be_installed }
  end

  describe package('oddjob-mkhomedir') do
    it { should be_installed }
  end

  describe service('oddjobd') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/etc/oddjobd.conf') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
  end

  describe file('/etc/pam.d/system-auth') do
    it { should exist }
    it { should be_file }
    its('content') { should match /session.+pam_oddjob_mkhomedir\.so umask=0077/ }
  end

  describe file('/etc/oddjobd.conf.d/oddjobd-mkhomedir.conf') do
    it { should exist }
    it { should be_file }
    its('content') { should_not match /0002/ }
  end
end
