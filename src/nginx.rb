control "nginx-1.0" do
  impact 1.0
  title 'nginx'
  desc "Validate nginx installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include?('nginx')
  end

  describe port(80) do
    it { should be_listening }
  end

  describe port(443) do
    it { should be_listening }
  end
end
