control "xl_relase-1.0" do
  impact 1.0
  title 'xl_release'
  desc "Validate xl-release installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'xl-release'
  end

  describe port(8080) do
    it { should be_listening }
  end

  describe user('xlr') do
    it { should exist }
  end

  describe service('xl-release') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/srv/xl-release/xl-release') do
    it { should exist }
    it { should be_symlink }
    its('owner') { should eq 'xlr' }
  end

  describe file('/srv/xl-release/xl-deploy-cli') do
    it { should exist }
    it { should be_symlink }
    its('owner') { should eq 'xlr' }
  end

  describe file('/srv/xl-release/xl-deploy-cli/bin') do
    it { should exist }
    it { should be_directory }
  end

  describe file('/srv/xl-release/xl-release/conf/xl-release.conf') do
    it { should exist }
    it { should be_file }
    its('size') { should > 10 }
    its('mode') { should emp '0644' }
    its('owner') { should eq 'xlr' }
    its('group') { should eq 'xlr' }
  end

  describe file('/srv/xl-release/xl-release/conf/xl-release-license.lic') do
    it { should exist }
    it { should be_file }
    its('mode') { should emp '0600' }
    its('owner') { should eq 'xlr' }
    its('group') { should eq 'xlr' }
  end

  describe file('/srv/xl-release/xl-release/conf/xl-release-security.xml') do
    it { should exist }
    it { should be_file }
    its('mode') { should emp '0644' }
    its('owner') { should eq 'xlr' }
    its('group') { should eq 'xlr' }
    its('content') { should match /.*tdbfg,DC=com.*/i }
  end

  describe file('/srv/xl-release/xl-release/conf/reference.conf') do
    it { should exist }
    it { should be_file }
    its('mode') { should emp '0644' }
    its('owner') { should eq 'xlr' }
    its('group') { should eq 'xlr' }
    its('content') { should match /.*defaultTimezone.*/i }
  end

  describe file('/srv/xl-release/xl-release/conf/xlr-wrapper-linux.conf') do
    it { should exist }
    it { should be_file }
    its('mode') { should emp '0664' }
    its('owner') { should eq 'xlr' }
    its('group') { should eq 'xlr' }
    its('content') { should match /.*jmxremote=true.*/i }
  end

  describe file('/srv/xl-release/xl-release/lib/yaml.jar') do
    it { should exist }
    it { should be_file }
    its('mode') { should emp '0644' }
    its('owner') { should eq 'xlr' }
    its('group') { should eq 'xlr' }
  end

  describe file('/srv/xl-release/xl-release/conf/logback.xml') do
    it { should exist }
    it { should be_file }
    its('mode') { should emp '0644' }
    its('owner') { should eq 'xlr' }
    its('group') { should eq 'xlr' }
    its('content') { should match /.*logger name=\"audit\" level=\"info\".*/i }
  end

  describe file('/srv/xl-release/xl-release/ext/jenkins') do
    it { should exist }
    it { should be_directory }
    its('owner') { should eq 'xlr' }
  end

  describe file('/opt/splunkforwarder/etc/apps/salt/local/inputs.conf') do
    it { should exist }
    it { should be_file }
    its('content') { should match(%r{\[monitor:///srv/xl-release/xl-release/log/access\.log\]\nindex = main\nsourcetype = xlr:access}) }
    its('content') { should match(%r{\[monitor:///srv/xl-release/xl-release/log/audit\.log\]\nindex = main\nsourcetype = xlr:audit}) }
    its('content') { should match(%r{\[monitor:///srv/xl-release/xl-release/log/xl-release\.log\]\nindex = main\nsourcetype = xlr:server}) }
    its('content') { should match(%r{\[monitor:///srv/xl-release/xl-release/log/wrapper\.log\]\nindex = main\nsourcetype = xlr:server}) }
  end

  describe command('ls /srv/xl-release/xl-release/plugins/xlr-application-descriptor*') do
    its('exit_status') { should eq 0 }
  end
end
