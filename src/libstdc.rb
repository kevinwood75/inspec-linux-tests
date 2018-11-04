control "libstdc-1.0" do
  impact 1.0
  title 'libstdc'
  desc "Validate libstdc installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat'
  end

  describe package('compat-libstdc++-33') do
    it { should be_installed }
  end
end