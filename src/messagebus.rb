control "messagebus-1.0" do
  impact 1.0
  title 'messagebus'
  desc "Validate messagebus installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['active_directory_joined']
  end

  describe package('dbus') do
    it { should be_installed }
  end

  if grains['osrelease'].start_with?('6')
    describe service('messagebus') do
      it { should be_enabled }
      it { should be_running }
    end
  elsif grains['osrelease'].start_with?('7')
    describe service('dbus') do
      it { should be_enabled }
      it { should be_running }
    end
  end 
end