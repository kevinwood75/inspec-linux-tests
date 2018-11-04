control "salt_minion-1.0" do
  impact 1.0
  title 'salt_minion'
  desc "Validate salt_minion installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat'
  end

  # check salt minion service
  describe service('salt-minion') do
    it { should be_running }
  end

  describe file('/etc/salt/minion.d/_schedule.conf') do
    it { should be_file }
  end

  describe file('/etc/salt/minion') do
    it { should be_file }
    its('content') { should match /include: minion.d\/\*.conf/ }
  end

  describe file('/etc/salt/minion.d/minion.conf') do
    it { should be_file }
    its('content') { should match /^backup_mode: minion/ }
  end
end
