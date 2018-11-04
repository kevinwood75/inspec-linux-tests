control "influxdb-1.0" do
  impact 1.0
  title 'influxdb'
  desc "Validate influxdb installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'influxdb'
  end

  [8083, 8086, 8088, 9088].each do |port|
    describe port(port) do
      it { should be_listening }
    end
  end
end
