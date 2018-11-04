control "aide-1.0" do
  impact 1.0
  title 'aide'
  desc "Validate aide installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat'
  end

  describe package('aide') do
    it { should be_installed }
  end

  describe file('/etc/aide.conf') do
    it { should exist }
    it { should be_file }
    its('md5sum') { should eq '17ae4d1a59488d40d06410eb46d7e30a' }
  end

  describe crontab('root').commands('/usr/sbin/aide --check') do
    its('hours') { should cmp '5' }
    its('minutes') { should cmp '0' }
  end

  describe file('/var/lib/aide/aide.db.gz') do
    it { should exist }
    it { should be_file }
  end
   
  describe file('/etc/audit/audit.rules') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('content') { should match(%r{-w /etc/aide.conf -p wa -k pillar-aide}) }
    its('content') { should match(%r{-w /var/lib/aide/aide.db.gz -p wa -k pillar-aide}) }
    its('content') { should match(%r{-w /var/lib/aide/aide.db.new.gz -p wa -k pillar-aide}) }
    its('content') { should match(%r{-w /var/log/aide/ -p wa -k pillar-aide}) }
  end
  
  describe file('/opt/splunkforwarder/etc/apps/salt/local/inputs.conf') do
    its('content') { should match(%r{\[monitor:///var/log/aide/aide\.log\]\nindex = main\nsourcetype = aide:aide}) }
  end

  if File.exists?('/etc/sysconfig/prelink')
    describe file('/etc/sysconfig/prelink') do
      its('content') { should match(%r{PRELINKING=no}) }
    end
    describe command('/usr/sbin/prelink -ya') do
      its('exit_status') { should eq 0 }
    end
  end
end
