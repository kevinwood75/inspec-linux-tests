gid = inspec.command('getent group itm').stdout.split(":")[2]
release = inspec.command("rpm -q --queryformat '%{RPMTAG_VERSION}%{RPMTAG_RELEASE}' TDitmc | sed 's/\\.//2g'").stdout.to_f

control "itm-1.0" do
  impact 1.0
  title 'itm'
  desc "Validate itm installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat'
  end

  describe group('itm') do
    it { should exist }
  end

  describe package('ksh') do
    it { should be_installed }
  end

  describe package('TDitmc') do
    it { should be_installed }
    unless gid.eql?('790')
      describe (release) do
        it { should be >= 6.345 }
      end
    end
  end

  itm_service_name = grains['os_family'] == 'Debian' ? 'itm' : 'ITMAgents1'

  describe service(itm_service_name) do
    it { should be_enabled }
  end

  #
  # Conf
  #
  describe grains['roles'] do
    it { should include 'itm_configured' }
  end

  describe file('/opt/IBM/ITM/config') do
    it { should exist }
    it { should be_directory }
    its('mode') { should cmp '0750' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'itm' }
  end

  describe file('/opt/IBM/ITM/config/td.config') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0640' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'itm' }
    its('content') { should match(/CMSCONNECT=1/) } # Value set from pillar data
    its('content') { should match(/HSNETWORKPROTOCOL=ip\.pipe/) } # Value set from pillar data
    its('content') { should match(/HOSTNAME=CPTIVT05\.TDBANK\.CA/) } # Value set from pillar data
    its('content') { should match(/NETWORKPROTOCOL=ip\.pipe/) } # Value set from pillar data
    its('content') { should match(/FTO=2/) } # Value set from pillar data
  end

  describe file('/opt/IBM/ITM/config/lz.config') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0770' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'itm' }
  end

  describe file('/opt/IBM/ITM/config/ul.config') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0770' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'itm' }
  end

  describe file('/etc/security/access.conf') do
    it { should exist }
    it { should be_file }
    its('content') { should match(/\+:its-oam-mts:ALL/) } # Value set via pillar data, pam_access: stanza
  end

  describe command('netstat -tulpn | grep agent') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/agent/) }
  end
end
