control "cloudops-1.0" do
  impact 1.0
  title 'cloudops'
  desc "Validate cloudops installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['osrelease'].start_with?('6')
  end

  describe package('CLOUDOPS_tools') do
    it { should be_installed }
  end
end
