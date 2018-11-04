control "vormetric-1.0" do
  impact 1.0
  title 'vormetric'
  desc "Validate vormetric installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'vormetric'
  end

  describe port(7024) do
    it { should be_listening }
  end
end