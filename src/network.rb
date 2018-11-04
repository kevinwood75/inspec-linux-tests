interface_files = inspec.command('ls -1 /etc/sysconfig/network-scripts/ifcfg-*|grep -v ifcfg-lo').stdout.split(" ")

control "network-1.0" do
  impact 1.0
  title 'network'
  desc "Validate network installation"

  params = salt_info
  grains = params.grains
  pillar = params.pillar
  
  only_if do
    grains['os_family'] == 'RedHat' and grains['osrelease'].start_with?('7')
  end

  inspec.command('ls -1 /etc/sysconfig/network-scripts/ifcfg-*|grep -v ifcfg-lo').stdout.split(" ").each do |interface_file|
    describe file(interface_file) do
      it { should exist }
      it { should be_file }
      its('content') { should match /ONBOOT="yes"/ }
      its('content') { should match /BOOTPROTO="dhcp"/ }
      its('content') { should match /USERCTL="no"/ }
      its('content') { should match /PEERDNS="no"/ }
      its('content') { should_not match /NM_CONTROLLED="no"/ }

      pillar['dns']['searchpaths'].each do |searchpath|
      	its('content') { should match /DOMAIN=".*#{searchpath}.*"/ }
      end

      pillar['dns']['nameservers'].each do |nameserver|
      	its('content') { should match /DNS.*=".*#{nameserver}.*"/ }
      end 
    end
  end
end