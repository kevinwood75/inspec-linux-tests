control "pm2-1.0" do
  impact 1.0
  title 'pm2'
  desc "Validate pm2 installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'pm2'
  end

  %w(java-1.8.0-openjdk oracle-instantclient12.2-basic oracle-instantclient12.2-devel jq rh-nodejs8).each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end

  describe user('pm2') do
    it { should exist }
  end

  %w(/opt/apis /opt/apis/app /opt/apis/config/lob /var/log/apis /opt/apis/config/etc).each do |d|
    describe file(d) do
      it { should exist }
      it { should be_directory }
      its('owner') { should eq 'pm2' }
      its('group') { should eq 'pm2' }
    end
  end

  %w(/etc/profile.d/node.sh /etc/scl/prefixes/rh-nodejs8 /etc/systemd/system/pm2.service).each do |f|
    describe file(f) do
      it { should exist }
      its('size') { should > 0 }
    end
  end

  describe service('pm2.service') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/etc/logrotate.d/pm2.conf') do
    it { should exist }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('size') { should > 0 }
  end

  describe file('/etc/scl/prefixes/rh-nodejs8') do
    its('content') { should match /\/opt\/rh/ }
  end

  describe file('/etc/profile.d/node.sh') do
    its('content') { should match /source scl_source enable rh-nodejs8/ }
    its('content') { should match /export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\/usr\/lib\/oracle\/12\.2\/client64\/lib\// }
  end

  describe command('curl http://localhost:3080/v1/api/info') do
    its('stdout') { should match /status/ }
    its('stdout') { should match /"serverStatusCode":"\d+"/ }
  end
end
