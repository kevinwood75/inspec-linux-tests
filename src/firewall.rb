control "firewall-1.0" do
  impact 1.0
  title 'firewall'
  desc "Validate firewall installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat'
  end

  if grains['osrelease'].start_with?('6')
    describe package('iptables') do
      it { should be_installed }
    end
  end

  if grains['osrelease'].start_with?('7')
    describe package('iptables-services') do
      it { should be_installed }
    end

    describe package('firewalld') do
      it { should_not be_installed }
    end
  end

  describe service('iptables') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/etc/sysconfig/iptables') do
    it { should exist }
    it { should be_file }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
  end
end