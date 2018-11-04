control "salt_master-1.0" do
  impact 1.0
  title 'salt_master'
  desc "Validate salt_master installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'saltmaster'
  end

  describe package('salt-master') do
    it { should be_installed }
  end

  describe package('salt-api') do
    it { should be_installed }
  end

  if grains['salt_master_production'] != 'True'
    describe package('python-pygit2') do
      it { should be_installed }
    end
  end

  # check salt master services enabled and running
  describe service('salt-master') do
    it { should be_enabled }
    it { should be_running }
  end

  describe service('salt-api') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/etc/salt/pki/master/master.pem') do
    it { should be_file }
    its('mode') { should cmp '0600' }
    its('owner') { should eq 'root'}
    its('group') { should eq 'root'}
  end

  describe file('/etc/salt/pki/master/master.pub') do
    it { should be_file }
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'root'}
    its('group') { should eq 'root'}
  end

  describe file('/etc/salt/master.d/master.conf') do
    it { should be_file }
  end

  describe file('/etc/salt/master.d/reactor.conf') do
    it { should be_file }
  end

  describe file ('/etc/salt/reactors') do
    it { should be_directory }
    # how to test if the directory has files??
  end

  describe file('/etc/salt/master') do
    it { should be_file }
  end

  describe file('/etc/salt/master.d/auth.conf') do
    it { should be_file }
  end

  describe file('/etc/default/salt') do
    it { should be_file }
    its('content') { should match /ulimit -n 100000\nSALTAPI=\/usr\/bin\/salt-api\nPYTHON=\/usr\/bin\/python2.6/m }
  end

  describe file('/etc/security/limits.d/99-salt.conf') do
    it { should be_file }
    its('content') { should match /root\s+hard\s+nofile\s+100000\nroot\s+soft\s+nofile\s+100000/m }
  end

  describe file('/etc/init.d/salt-api') do
    it { should be_file }
    its('content') { should match /CONFIG_ARGS="-d --log-file=\/var\/log\/salt\/api --log-file-level=info"/ }
  end

  describe file('/etc/logrotate.d/salt-api') do
    it { should be_file }
  end

  describe file('/etc/salt/master.d/api.conf') do
    it { should be_file }
  end
end


control "salt_master_net-1.0" do
  impact 1.0
  title 'salt_master_net'
  desc "Validate salt_master installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and (grains['roles'].include? 'saltmaster' or grains['roles'].include? 'saltsyndic')
  end

  describe port(4505) do
    it { should be_listening }
  end

  describe port(4506) do
    it { should be_listening }
  end
end

control "salt_master_master-1.0" do
  impact 1.0
  title 'salt_master_master'
  desc "Validate salt_master installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'master_of_masters'
  end

  describe port(5000) do
    it { should be_listening }
  end

  describe port(5500) do
    it { should be_listening }
  end
end
