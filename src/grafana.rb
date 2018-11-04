control "grafana-1.0" do
  impact 1.0
  title 'grafana'
  desc "Validate grafana installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat'
  end

  if grains['roles'].include? 'grafana'
    describe port(3000) do
      it { should be_listening }
    end
  end
end
