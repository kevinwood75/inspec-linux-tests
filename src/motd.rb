control "motd-1.0" do
  impact 1.0
  title 'motd'
  desc "Validate motd installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat'
  end

  describe file('/etc/motd') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('content') { should match /Host controlled by SaltStack/ }
  end

  if grains['os'] == 'Ubuntu'
    describe file('/etc/update-motd.d') do
      it { should_not exist }
    end
  end
end