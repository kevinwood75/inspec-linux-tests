control "rundeckpro-1.0" do
  impact 1.0
  title 'rundeckpro'
  desc "Validate rundeckpro installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'rundeckpro'
  end

  [8005, 8009, 4440, 4443].each do |p|
    describe port(p) do
      it { should be_listening }
    end
  end
end
