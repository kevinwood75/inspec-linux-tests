control "rsyslog-1.0" do
  impact 1.0
  title 'rsyslog'
  desc "Validate rsyslog installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat'
  end

  describe package('rsyslog') do
    it { should be_installed }
  end

  describe service('rsyslog') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/etc/rsyslog.d/10-iptables.conf') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('content') { should match /-\/var\/log\/iptables\.log/ }
  end

  env = grains['environment']
  if env == 'prod'
    rsyslog_ip = '49.9.230.183'
  else
    rsyslog_ip = '49.9.230.181'
  end

  describe file('/etc/rsyslog.d/20-thg-audit.conf') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('content') { should match /\$template THGFormat,/ } 
    its('content') { should match /#{rsyslog_ip}/ } 
    its('content') { should match /\*\.info\s+@.*;THGFormat/ } 
  end

  describe file('/etc/rsyslog.d/30-strong-pm.conf') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('content') { should match /\/var\/log\/strong-pm\.log/ }
  end

  describe crontab('root') do
    its('commands') { should include 'salt-call state.sls rsyslog.included' }
  end
end