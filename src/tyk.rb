control "tyk-1.0" do
  impact 1.0
  title 'tyk'
  desc "Validate tyk installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'tyk'
  end

  describe port(8080) do
    it { should be_listening }
  end

  describe port(3000) do
    it { should be_listening }
  end
end