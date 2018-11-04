control "hostname-1.0" do
  impact 1.0
  title 'hostname'
  desc "Validate hostname"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['osrelease'].start_with?('7')
  end

  describe file('/etc/cloud/cloud.cfg.d/preserve_hostname.cfg') do
    it { should exist }
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('content') { should match(%r{preserve_hostname: true}) }
  end
end
