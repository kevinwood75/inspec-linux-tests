control "diamond-1.0" do
  impact 1.0
  title 'diamond'
  desc "Validate diamond installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat'
  end

  describe group('secroot') do
    it { should exist }
    its('gid') { should eq 1802 }
  end

  describe user('batch') do
    it { should exist }
    its('group') { should eq 'secroot' }
    its('uid') { should eq 199 }
    its('shell') { should eq '/bin/bash' }
  end

  describe file('/etc/shadow') do
  	it { should exist }
  	its('content') { should match(%r{batch:\*})}
  end

  describe file('/home/batch/.ssh/authorized_keys') do
  	it { should exist }
    # ssh public key is the same across all environments
  	its('content') { should match(%r{ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQCrjMm3uVsDGZc0tGyJz\+kv\+vgi0qSKspSeelEHOBn1T/Atvglrmqfl7\+tla28vY\+JJo8gUlIZWconiOy\+vuXZe/BDH79PCUom792jlDHj474a0/dY2zGA9jlD59xFf6QnE3mPI6T6pcB5NBo5LiZKNja5QZSwsp2\+e9V8CkJvs2w== batch lgsrv 20081126}) }
  end


  describe file('/etc/sudoers') do
    its('content') { should match(%r{batch ALL=\(ALL\) NOPASSWD: /usr/local/bin/diamond-c62-collect\.sh}) }
  end

  describe file('/usr/local/bin/diamond-c62-collect.sh') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('mode') { should cmp '0770' }
    its('md5sum') { should eq '604f61812bdac600d8ecc80f01855a78' }
  end

  describe file('/etc/security/access.conf') do
    its('content') { should match(%r{\+:batch:49\.16\.159\.93,49\.16\.159\.94,10\.113\.48\.60}) }
  end
end