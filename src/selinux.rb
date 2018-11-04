control "salt_master-1.0" do
  impact 1.0
  title 'salt_master'
  desc "Validate salt_master installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['osmajorrelease'].to_i == 6
  end

  describe command('sestatus | grep -qi "Current mode:\s+enforcing"') do
  	its('exit_status') { should eq 1 }
  end
end