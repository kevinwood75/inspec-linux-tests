control "sensu_client-1.0" do
  impact 1.0
  title 'sensu_client'
  desc "Validate sensu_client installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'sensu_client'
  end

  describe package('sensu') do
    it { should be_installed }
  end
  
  describe service('sensu-client') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/opt/sensu') do
    it { should exist }
    it { should be_directory }
  end

  describe file('/opt/sensu/embedded/bin') do
    it { should exist }
    it { should be_directory }
  end
  
  # Testing existance of conf.d as well
  describe file('/etc/sensu/conf.d/client.json') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'sensu' }
    its('group') { should eq  'sensu' }
  end
  
  describe file('/etc/sensu/conf.d/rabbitmq.json') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'sensu' }
    its('group') { should eq  'sensu' }
  end

  describe json('/etc/sensu/conf.d/rabbitmq.json') do
    its(['rabbitmq', 'ssl', 'cert_chain_file']) { should eq '/etc/sensu/ssl/cert.pem' }
  end
  
  describe file('/etc/sensu/conf.d/checks.json') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'sensu' }
    its('group') { should eq  'sensu' }
    its('content') { should match(%r{/opt/sensu/embedded/bin/check-cpu.rb -w 90 -c 98}) }
    its('content') { should match(%r{/opt/sensu/embedded/bin/check-disk-usage.rb -c 90 -w 80 -i /boot}) }
    its('content') { should match(%r{/opt/sensu/embedded/bin/check-load.rb -c 5,5,5 -w 1,1,1}) }
    its('content') { should match(%r{/opt/sensu/embedded/bin/check-process.rb -p crond -C 1}) }
    its('content') { should match(%r{python /opt/sensu/plugins/check-linux-memoryswap.py -si 30000 -o CHECK}) }
    its('content') { should match(%r{python /opt/sensu/plugins/check-linux-memoryswap.py -so 40000 -o CHECK}) }
    its('content') { should match(%r{python /opt/sensu/plugins/check-linux-reboot.py -f 6.0 -o CHECK}) }
  end
  
  describe file('/etc/sensu/conf.d/metrics.json') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'sensu' }
    its('group') { should eq  'sensu' }
    its('content') { should match(%r{/opt/sensu/embedded/bin/metrics-cpu-pcnt-usage.rb}) }
    its('content') { should match(%r{/opt/sensu/embedded/bin/metrics-memory-percent.rb}) }
    its('content') { should match(%r{/opt/sensu/embedded/bin/metrics-memory.rb}) }
    its('content') { should match(%r{/opt/sensu/embedded/bin/metrics-cpu-pcnt-usage.rb}) }
    its('content') { should match(%r{/opt/sensu/embedded/bin/metrics-cpu-mpstat.rb}) }
    its('content') { should match(%r{/opt/sensu/embedded/bin/metrics-user-pct-usage.rb}) }
    its('content') { should match(%r{/opt/sensu/embedded/bin/metrics-disk-capacity.rb}) }
    its('content') { should match(%r{/opt/sensu/embedded/bin/metrics-disk.rb}) }
    its('content') { should match(%r{/opt/sensu/embedded/bin/metrics-disk-usage.rb}) }
    its('content') { should match(%r{/opt/sensu/embedded/bin/metrics-interface.rb}) }
    its('content') { should match(%r{/opt/sensu/embedded/bin/metrics-load.rb}) }
    its('content') { should match(%r{/opt/sensu/embedded/bin/metrics-sockstat.rb}) } 
    its('content') { should match(%r{/opt/sensu/embedded/bin/metrics-load.rb}) }
    its('content') { should match(%r{/opt/sensu/embedded/bin/metrics-netif.rb}) }
    its('content') { should match(%r{/opt/sensu/embedded/bin/metrics-netstat-tcp.rb}) }
  end
  
  # Check keys
  describe file('/etc/sensu/ssl/key.pem') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0640' }
    its('owner') { should eq 'sensu' }
    its('group') { should eq  'sensu' }
    its('md5sum') { should eq '6549b50b14d49f2b42d65d0630930890' }
  end
  
  describe file('/etc/sensu/ssl/cert.pem') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0640' }
    its('owner') { should eq 'sensu' }
    its('group') { should eq  'sensu' }
    its('md5sum') { should eq 'a6a14ed697e396bb19e4d1bfdc2cd96b' }
  end
  
  # Check embedded_ruby is set to True
  describe file('/etc/default/sensu') do
    it { should exist }
    it { should be_file }
    its('content') { should match /EMBEDDED_RUBY=true/ }
  end

end