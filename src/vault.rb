control "vault-1.0" do
  impact 1.0
  title 'vault'
  desc "Validate vault installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'vault'
  end

  describe port(8200) do
    it { should be_listening }
  end

  describe port(8443) do
    it { should be_listening }
  end
end