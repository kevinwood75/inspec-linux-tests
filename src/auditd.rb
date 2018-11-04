control "auditd-1.0" do
  impact 1.0
  title 'auditd'
  desc "Validate auditd installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat'
  end

  describe package('audit') do
    it { should be_installed }
  end

  describe service('auditd') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/etc/audit/auditd.conf') do
    it { should exist }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('md5sum') { should eq '2737872bdca0e8cec01508142b749340' }
  end

  describe.one do
    describe file('/etc/audit/auditd.conf') do
      its('mode') { should cmp '0644' }
    end
    describe file('/etc/audit/auditd.conf') do
      its('mode') { should cmp '0640' }
    end
  end

  describe file('/etc/audit/audit.rules') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('mode') { should cmp '0640' }
    its('content') { should match(%r{-w /var/log/audit -p wa -k pillar-auditd}) }
    its('content') { should match(%r{-w /etc/audit/ -p wa -k pillar-auditd}) }
    its('content') { should match(%r{-w /etc/sysconfig/auditd -p wa -k pillar-auditd}) }
    its('content') { should match(%r{-w /etc/libaudit.conf -p wa -k pillar-auditd}) }
    its('content') { should match(%r{-w /etc/audisp -p wa -k pillar-auditd}) }
  end
  
  describe file ('/opt/splunkforwarder/etc/apps/salt/local/inputs.conf') do
    its('content') { should match(%r{\[monitor:///var/log/audit/audit\.log\]\nindex = main\nsourcetype = auditd:audit}) }
  end
  
  describe crontab('root').commands('salt-call state.sls auditd') do
    its('hours') { should cmp '2' }
    its('minutes') { should cmp '0' }
  end
end