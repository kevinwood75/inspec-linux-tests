control "xl_deploy-1.0" do
  impact 1.0
  title 'xl_deploy'
  desc "Validate xl-deploy installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'xl-deploy'
  end

  describe port(8080) do
    it { should be_listening }
  end

  describe user('xld') do
    it { should exist }
  end

  describe service('xl-deploy') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/srv/xl-deploy/xl-deploy') do
    it { should exist }
    it { should be_symlink }
    its('owner') { should eq 'xld' }
  end

  describe file('/srv/xl-deploy/xl-deploy/conf/deployit.conf') do
    it { should exist }
    it { should be_file }
    its('size') { should > 10 }
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'xld'}
    its('group') { should eq 'xld' }
  end

  describe file('/srv/xl-deploy/xl-deploy/conf/deployit-license.lic') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0600' }
    its('owner') { should eq 'xld'}
    its('group') { should eq 'xld' }
  end

  describe file('/srv/xl-deploy/xl-deploy/conf/deployit-security.xml') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'xld'}
    its('group') { should eq 'xld' }
    its('content') { should match /.*tdbfg,DC=com.*/i }
  end

  describe file('/srv/xl-deploy/xl-deploy/conf/xld-wrapper-linux.conf') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0664' }
    its('owner') { should eq 'xld'}
    its('group') { should eq 'xld' }
    its('content') { should match /.*jmxremote=true.*/i }
  end

  describe command('ls /srv/xl-deploy/xl-deploy/plugins/xld-salt-plugin*') do
    its('exit_status') { should eq 0 }
  end
end
