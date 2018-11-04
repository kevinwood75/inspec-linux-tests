control "mongodb32-1.0" do
  impact 1.0
  title 'mongodb32'
  desc "Validate mongodb32 installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include?('mongodb32')
  end

  %w(
  lvm2 
  bc 
  xorg-x11-xauth 
  dos2unix 
  zip 
  mongodb-enterprise-tools
  mongodb-enterprise-server 
  mongodb-enterprise-shell).each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end

  describe group('mongod') do
    it { should exist }
    its('gid') { should eq 3442 }
  end

  describe user('mongod') do
    it { should exist }
    its('uid') { should eq 86285 }
    its('home') { should eq '/mongod' }
    its('shell') { should eq '/bin/bash' }
    its('group') { should eq 'mongod' }
  end
  
  describe port(27017) do
    it { should be_listening }
  end
end