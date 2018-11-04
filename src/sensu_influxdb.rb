files = inspec.command('ls /etc/influxdb').stdout.split("\n")

control "sensu_influxdb-1.0" do
  impact 1.0
  title 'sensu_influxdb'
  desc "Validate sensu_influxdb installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'influxdb-server'
  end

  describe (grains['influxdb_leader']) do
    it { should_not be_nil }
  end

  if files.include? "influxdb.conf"
    describe service('influxdb') do
      it { should be_enabled }
    end

    describe service('influxdb-meta') do
      it { should be_running }
    end

    describe port(8091) do
      it { should be_listening }
    end
  end

  if files.include? "influxdb-meta.conf"
    describe service('influxdb-meta') do
      it { should be_enabled }
    end

    describe service('influxdb-meta') do
      it { should be_running }
    end

    describe port(8088) do
      it { should be_listening }
    end
  end

  describe command('influxd-ctl show') do
    its('stdout') { should match /#{grains[id]}/ }
  end
end
