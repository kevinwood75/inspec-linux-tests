manager_ip = inspec.command('source /etc/default/celeryd-*; echo -n $MANAGEMENT_IP').stdout

control "pam-1.0" do
  impact 1.0
  title 'pam'
  desc "Validate pam installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat'
  end

  describe package('pam') do
    it { should be_installed }
  end

  describe file('/etc/security/access.conf') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('content') { should match /\+:cloud-user:#{manager_ip}/ }
    its('content') { should_not match /\+:cloud-user:ALL/ }   
  end
  
  describe command('grep -Eq "^account.*required.*pam_access.so" /etc/pam.d/system-auth') do
    its('exit_status') { should eq 0 }
  end
  
  #EWS adds a file located in the same directory '/etc/pam.d/atd'  this file does not get modified by the state - so list for exact files here
  describe command('PAM_FILES=$(grep -l "pam_access.so listsep=," /etc/pam.d/*); for i in $PAM_FILES; do grep -Eq "pam_access.so listsep=," $i || exit 1; done') do
     its('exit_status') { should eq 0 }
  end
  
  describe file('/etc/audit/audit.rules') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0640' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('content') { should match(%r{-w /etc/pam\.d/ -p wa -k pillar-pam}) }
    its('content') { should match(%r{-w /etc/security/access\.conf -p wa -k pillar-pam}) }
    its('content') { should match(%r{-w /etc/security/limits\.conf -p wa -k pillar-pam}) }
    its('content') { should match(%r{-w /etc/security/pam_env\.conf -p wa -k pillar-pam}) }
    its('content') { should match(%r{-w /etc/security/namespace\.conf -p wa -k pillar-pa}) }
    its('content') { should match(%r{-w /etc/security/namespace\.d/ -p wa -k pillar-pam}) }
    its('content') { should match(%r{-w /etc/security/namespace\.init -p wa -k pillar-pam}) }
    its('content') { should match(%r{-w /etc/security/sepermit\.conf -p wa -k pillar-pam}) }
    its('content') { should match(%r{-w /etc/security/time\.conf -p wa -k pillar-pam}) }
  end
end
