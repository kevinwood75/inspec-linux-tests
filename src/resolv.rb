control "resolv-1.0" do
  impact 1.0
  title 'resolv'
  desc "Validate resolv installation"

  params = salt_info
  grains = params.grains
  pillar = params.pillar
  
  only_if do
    grains['os_family'] == 'RedHat'
  end

  # Only one of the below tests is RHEL6 specfic
  describe file('/etc/resolv.conf') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    # TODO: Test Searchpaths (this information is depended on the environment 'zones')
    pillar['clouds']['current']['nameservers'].each { |nameserver|
      its('content') { should match /nameserver #{nameserver}/ }
    }
    if grains['osrelease'].start_with?('6')
        its('content') { should match /options single-request-reopen/ }
    end
  end
end
