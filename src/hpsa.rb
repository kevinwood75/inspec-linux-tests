control "hpsa-1.0" do
  impact 1.0
  title 'hpsa'
  desc "Validate hpsa installation"

  params = salt_info
  grains = params.grains
  pillar = params.pillar
  
  only_if do
    grains['os_family'] == 'RedHat'
  end

  describe package('TDhpsa') do
    it { should be_installed }
  end

  describe package('TDhpsa_tools') do
    it { should be_installed }
  end

  describe service('opsware-agent') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/var/opt/opsware') do
    it { should exist }
    it { should be_directory }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0755' }
  end

  describe file('/etc/opt/opsware/agent/opswgw.args') do
    it { should be_file }
    its('content') { should match(%r{#{pillar['hpsa']['install']['gateway']}}) }
  end

  describe file('/etc/opt/opsware/agent/mid') do
    it { should exist }
    it { should be_file }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0644' }
  end

  describe command('/opt/opsware/agent/pylibs/cog/bs_hardware') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(%r{Contacting core.*\nOpsware machine ID : }) }
  end

  describe port(1002) do
    it { should be_listening }
  end

  #
  # Service checking
  #
  if grains['osmajorrelease'].to_i == 6
    %w(rpcbind nfslock).each do |srv|
      describe service(srv) do
        it { should_not be_running }
        it { should_not be_enabled }
      end
    end
  end

  if grains['osmajorrelease'].to_i == 7
    %w(nfs rpcbind.socket nfs-client.target rpc-gssd).each do |srv|
      describe service(srv) do
        it { should_not be_running }
      end
      unless srv.eql?('rpc-gssd')
        describe service(srv) do
          it { should_not be_enabled }
        end
      end
    end
  end

  #
  # File content and permissions checking
  #
  describe file('/etc/shells') do
    it { should be_file }
    its('content') { should match(%r{/bin/false}) }
  end

  describe file('/etc/securetty') do
    it { should be_file }
    its('content') { should match(/console/) }
    its('content') { should match(/tty0/) }
    its('content') { should match(/tty1/) }
    its('content') { should match(/ttyS0/) }
  end

  describe file('/root/.cshrc') do
    its('mode') { should cmp '0640' }
  end

  describe file('/root/.tcshrc') do
    its('mode') { should cmp '0640' }
  end

  describe file('/root/.bashrc') do
    its('mode') { should cmp '0640' }
  end

  describe file('/root/.bash_profile') do
    its('mode') { should cmp '0640' }
  end

  #
  # Checking the passwords of these users are locked
  #
  describe file('/etc/shadow') do
    it { should exist }
    its('content') { should match(%r{batch:[*!]{1,2}}) }
    its('content') { should match(%r{pcfmapp:[*!]{1,2}}) }
    its('content') { should match(%r{qualys:[*!]{1,2}}) }
  end

  #
  # Parameters for password quality
  #
  describe file('/etc/security/pwquality.conf') do
    it { should be_file }
    its('content') { should match(/dcredit = -1/) }
    its('content') { should match(/lcredit = -1/) }
    its('content') { should match(/ocredit = -1/) }
    its('content') { should match(/ucredit = -1/) }
    its('content') { should match(/minlen = 8/) }
  end

  describe file('/etc/login.defs') do
    it { should be_file }
    its('content') { should match(/PASS_MIN_LEN 8/)}
  end

  describe file('/etc/pam.d/system-auth') do
    it { should be_file }
    its('content') { should match(/password\s+required\s+pam_pwhistory.so remember=8/) }
  end
end
