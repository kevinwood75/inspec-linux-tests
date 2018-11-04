control "mysql-1.0" do
  impact 1.0
  title 'mysql'
  desc "Validate mysql installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include?('mysql')
  end

  describe port(3306) do
    it { should be_listening }
  end
end
