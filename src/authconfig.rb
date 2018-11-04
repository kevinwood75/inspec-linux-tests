control "audthconfig-1.0" do
  impact 1.0
  title 'authconfig'
  desc "Validate authconfig installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat'
  end

  describe package('authconfig') do
    it { should be_installed }
  end

  describe service('auditd') do
    it { should be_enabled }
    it { should be_running }
  end

  if grains['osrelease'].start_with?('6') then
    describe command("echo \"$(rpm -qa --queryformat '%{version}.%{release}' authconfig|sed -e 's/\\.//2g' -e 's/el.*$//') >= 6.11219\" |bc -l") do
      its('stdout') { should eq "1\n"  }
    end
  end
  if grains['osrelease'].start_with?('7') then
    describe command("echo \"$(rpm -qa --queryformat '%{version}.%{release}' authconfig|sed -e 's/\\.//2g' -e 's/el.*$//') >= 6.2814\" |bc -l") do
      its('stdout') { should eq "1\n" }
    end
  end

  describe file('/etc/sysconfig/authconfig') do
    it { should exist }
    it { should be_file }
  end
end
