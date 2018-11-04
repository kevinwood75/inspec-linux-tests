control "rabbitmq-1.0" do
  impact 1.0
  title 'rabbitmq'
  desc "Validate rabbitmq installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'rabbitmq'
  end

  describe port(5672) do
    it { should be_listening }
  end

  describe port(56721) do
    it { should be_listening }
  end  
end
