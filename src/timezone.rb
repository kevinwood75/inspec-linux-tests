control "timezone-1.0" do
  impact 1.0
  title 'timezone'
  desc "Validate timezone installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat'
  end

  if grains['osrelease'].start_with?('6')
    describe file('/etc/sysconfig/clock') do
      it { should exist }
      it { should be_file }
      its('mode') { should cmp '0644' }
      its('owner') { should eq 'root'}
      its('group') { should eq 'root' }
      its('content') { should match /ZONE="America\/Toronto"/ }
    end

    # Check current hardware clock setting is UTC
    describe file('/etc/adjtime') do
      it { should exist }
      it { should be_file }
      its('mode') { should cmp '0644' }
      its('owner') { should eq 'root'}
      its('group') { should eq 'root' }
      its('content') { should match /^UTC$/ }
    end
  elsif grains['osrelease'].start_with?('7')
    describe command("timedatectl") do
      its('exit_status') { should eq 0 }
      its('stdout') { should match /Time zone.*America\/Toronto/ }
      its('stdout') { should match /RTC in local TZ.*no/ }
    end
  end

  describe file('/etc/localtime') do
    it { should exist }
    it { should be_file }
  end
  
  describe file('/usr/share/zoneinfo') do
    it { should exist }
    it { should be_directory }
  end
  
  describe command('cmp /etc/localtime /usr/share/zoneinfo/America/Toronto') do
    its('exit_status') { should eq 0 }
  end  
end
