hostname = inspec.command('hostname -f').stdout.strip

control "openssh-1.0" do
  impact 1.0
  title 'openssh'
  desc "Validate openssh installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat'
  end

  describe salt_info do
    it { should exist }
    its('grains') { should_not eq nil }
  end

  describe package('openssh-server') do
    it { should be_installed }
  end
  
  describe service('sshd') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(22) do
    it { should be_listening }
  end

  describe file('/etc/ssh/sshd_config') do
    its('md5sum'){ should eq '0a80b96166e6eb30d5140315dcab9a2c'}
  #   it { should exist }
  #   it { should be_file }
  #   its('mode') { should cmp '0600' }
  #   its('owner') { should eq 'root' }
  #   its('group') { should eq 'root' }
  #   its('content') { should match /^Port 22$/ }
  #   its('content') { should match /^#ListenAddress ::$/ }
  #   its('content') { should match /^#ListenAddress 0.0.0.0$/ }
  #   its('content') { should match /^Protocol 2$/ }
  #   its('content') { should match /^HostKey \/etc\/ssh\/ssh_host_rsa_key$/ }
  #   its('content') { should match /^HostKey \/etc\/ssh\/ssh_host_dsa_key$/ }
  #   its('content') { should match /^UsePrivilegeSeparation yes$/ }
  #   its('content') { should match /^KeyRegenerationInterval 3600$/ }
  #   its('content') { should match /^ServerKeyBits 768$/ }
  #   its('content') { should match /^SyslogFacility AUTH$/ }
  #   its('content') { should match /^LogLevel INFO$/ }
  #   its('content') { should match /^LoginGraceTime 120$/ }
  #   its('content') { should match /^PermitRootLogin yes$/ }
  #   its('content') { should match /^StrictModes yes$/ }
  #   its('content') { should match /^#DSAAuthentication yes$/ }
  #   its('content') { should match /^RSAAuthentication yes$/ }
  #   its('content') { should match /^PubkeyAuthentication yes$/ }
  #   its('content') { should match /^#AuthorizedKeysFile %h\/\.ssh\/authorized_keys$/ }
  #   its('content') { should match /^IgnoreRhosts yes$/ }
  #   its('content') { should match /^RhostsRSAAuthentication no$/ }
  #   its('content') { should match /^HostbasedAuthentication no$/ }
  #   its('content') { should match /^#IgnoreUserKnownHosts yes$/ }
  #   its('content') { should match /^PermitEmptyPasswords no$/ }
  #   its('content') { should match /^ChallengeResponseAuthentication no$/ }
  #   its('content') { should match /^PasswordAuthentication yes$/ }
  #   its('content') { should match /^#KerberosAuthentication no$/ }
  #   its('content') { should match /^#KerberosGetAFSToken no$/ }
  #   its('content') { should match /^#KerberosOrLocalPasswd yes$/ }
  #   its('content') { should match /^#KerberosTicketCleanup yes$/ }
  #   its('content') { should match /^#GSSAPIAuthentication no$/ }
  #   its('content') { should match /^#GSSAPICleanupCredentials yes$/ }
  #   its('content') { should match /^X11Forwarding yes$/ }
  #   its('content') { should match /^#AllowTcpForwarding yes$/ }
  #   its('content') { should match /^X11DisplayOffset 10$/ }
  #   its('content') { should match /^PrintMotd no$/ }
  #   its('content') { should match /^PrintLastLog yes$/ }
  #   its('content') { should match /^TCPKeepAlive yes$/ }
  #   its('content') { should match /^#UseLogin no$/ }
  #   its('content') { should match /^#MaxStartups 10:30:60$/ }
  #   its('content') { should match /^Banner \/etc\/ssh\/banner$/ }
  #   its('content') { should match /^AcceptEnv LANG LC_\*$/ }
  #   its('content') { should match /^Subsystem sftp \/usr\/libexec\/openssh\/sftp-server$/ }
  #   its('content') { should match /^UsePAM yes$/ }
  #   its('content') { should match /^UseDNS yes$/ }
  end

  describe file('/etc/ssh/banner') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('content') { should match /This host is managed by SaltStack!/ }
    its('content') { should match /#{hostname}/ }
  end

  describe file('/etc/audit/audit.rules') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0640' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('content') { should match /-w \/etc\/ssh\/sshd_config -p wa -k pillar-openssh/ }
    its('content') { should match /-w \/etc\/issue -p wa -k pillar-openssh/ }
    its('content') { should match /-w \/etc\/issue.net -p wa -k pillar-openssh/ }
  end
end
