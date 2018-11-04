control "grub-1.0" do
  impact 1.0
  title 'grub'
  desc "Validate grub installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat'
  end

  if grains['osrelease'].start_with?('6')
    describe file('/boot/grub/grub.conf') do
      its('content') { should match(%r{^\s*kernel.*audit=1.*$}) }
    end
  end

  if grains['osrelease'].start_with?('7')
    describe file('/etc/default/grub') do
      its('content') { should match(%r{^.*GRUB_CMDLINE_LINUX.*audit=1.*$}) }
    end
  end
end
