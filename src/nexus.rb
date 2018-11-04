control "nexus-1.0" do
  impact 1.0
  title 'nexus'
  desc "Validate nexus installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and (grains['roles'].include?('nexus') or grains['roles'].include?('nexusproxy'))
  end

  describe port(8081) do
    it { should be_listening }
  end
end