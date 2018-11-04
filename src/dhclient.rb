control "dhclient-1.0" do
  impact 1.0
  title 'dhclient'
  desc "Validate dhclient installation"

  params = salt_info
  grains = params.grains
  pillar = params.pillar

  only_if do
    grains['os_family'] == 'RedHat'
  end

  describe package('dhclient') do
    it { should be_installed }
  end
  
  describe processes('dhclient') do
    it { should exist }
    its('users') { should eq ['root'] }
  end

  inspec.command('bash -c "ls /etc/dhcp/dhclient-eth*"').stdout.split("\n").each do |f|  	
    describe file(f) do
      it { should exist }
      it { should be_file }
      its('owner') { should eq 'root' }
      its('group') { should eq 'root' }
      its('mode') { should cmp '0644' }
      # TODO: Test Searchpaths (this information is depended on the environment 'zones')
      its('content') { should match(%r{domain-name-servers #{pillar['clouds']['current']['nameservers'].join(", ")}}) }
    end
  end
  
  inspec.command('bash -c "ls /etc/sysconfig/network-scripts/ifcfg-eth*"').stdout.split("\n").each do |fname|
    describe file(fname) do
      it { should exist }
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      its('mode') { should cmp '0644' }
      its('content') { should match(%r{peerdns\s*=\s*"?no"?}i) }
    end
  end

  describe file('/etc/dhcp/dhclient.d') do
    it { should exist }
    it { should be_directory }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0755' }
  end
end

