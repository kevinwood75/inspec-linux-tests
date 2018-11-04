control "bind-1.0" do
  impact 1.0
  title 'bind'
  desc "Validate bind installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and (grains['roles'].include? 'dns-master' or grains['roles'].include? 'dns-slave')
  end

  describe port(53) do
  	it { should be_listening }
    its('protocols') { should include 'tcp' }
    its('protocols') { should include 'udp' }
  end
end
