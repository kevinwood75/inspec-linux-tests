manager_ip = inspec.command('source /etc/default/celeryd-*; echo -n $MANAGEMENT_IP').stdout

control "pip-1.0" do
  impact 1.0
  title 'pip'
  desc "Validate pip installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat'
  end

  describe package('python-pip') do
    it { should be_installed }
  end

  describe file('/root/.pip') do
    it { should exist }
    it { should be_directory }
  end
  
  describe file('/root/.pip/pip.conf') do
    it { should exist }
    it { should be_file }
    its('content') { should match /timeout = 60/ }
    its('content') { should match /index-url = http:\/\/pypi01\.mgmt1\.cloud\.td\.com\/simple/ }
    its('content') { should match /trusted-host = pypi01\.mgmt1\.cloud\.td\.com/ }
  end
end
