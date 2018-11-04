control "haproxy-1.0" do
  impact 1.0
  title 'haproxy'
  desc "Validate haproxy installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'haproxy'
  end

  [80, 443, 7999, 5432, 5671, 4567, 2003, 8086, 8090].each do |port|
    describe port(port) do
      it { should be_listening }
    end
  end
end
