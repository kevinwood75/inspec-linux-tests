control "sysctl-1.0" do
  impact 1.0
  title 'sysctl'
  desc "Validate sysctl installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat'
  end

  # run test on both rhel6 and rhel7
  describe package('ip6tables') do
    it { should_not be_installed }
  end

  describe command('netstat -peant | grep ip6tables') do
    # check to see if the service is disabled and not running 
    its('exit_status') { should eq 1 }
    its('stdout') { should match // }
  end

  if grains['osrelease'].start_with?('6')
    describe command('sysctl net.ipv6.conf.all.disable_ipv6') do
      its('exit_status') { should eq 0 }
      its('stdout') { should match /net\.ipv6\.conf\.all\.disable_ipv6 = 1/ }
    end

    describe command('sysctl net.ipv6.conf.default.disable_ipv6') do
      its('exit_status') { should eq 0 }
      its('stdout') { should match /net\.ipv6\.conf\.default\.disable_ipv6 = 1/ }
    end
  end
end
