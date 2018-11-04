control "commvault-1.0" do
  impact 1.0
  title 'commvault'
  desc "Validate commvault installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat'
  end

  describe service('Galaxy') do
    it { should be_enabled }
    it { should be_running }
  end
  
  describe processes('cvd') do
    it { should exist }
    its('users') { should eq ["root"] }
  end
  
  describe processes('EvMgrC') do
    it { should exist }
    its('users') { should eq ["root"] }
  end
  
  describe processes('cvlaunchd') do
    it { should exist }
    its('users') { should eq ["root"] }
  end
  
  describe package(grains['roles'].include?('oracle') ? 'TDoracommvault-1.0.0' : 'TDcommvault-1.0.0') do
  	it { should be_installed }
  end

  if grains['roles'].include? 'oracle'
    describe file('/opt/hds/set_db_policy.xml') do
      it { should exist }
      it { should be_file }
      its('mode') { should cmp '0640' }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end
  end
  
  describe file('/opt/hds/set_cloud_policy.xml') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0640' }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end

  describe file('/etc/sensu/conf.d/checks.json') do
    it { should exist }
    it { should be_file }
    its('content') { should match(%r{"base_linux_process_commvault_cvd": \{\n *"command": "/opt/sensu/embedded/bin/check-process.rb -p cvd -C 1",}) }
    its('content') { should match(%r{"base_linux_process_commvault_EvMgrC": \{\n *"command": "sudo python /opt/sensu/plugins/commvault_process.py",}) }
    # This is old crap: not working
    # its('content') { should match(%r{"base_linux_process_commvault_EvMgrC": \{\n *"command": "/opt/sensu/embedded/bin/check-process.rb -p EvMgrC -C 1",}) }
  end
end
