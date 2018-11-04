control "jenkins_slave-1.0" do
  impact 1.0
  title 'jenkins'
  desc "Validate jenkins slave installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'jenkins-slave'
  end

  describe user('jenkins') do
    it { should exist }
    its('group') { should eq 'jenkins' }
    its('home') { should eq '/home/jenkins' }
  end

  describe group('jenkins') do
    it { should exist }
  end

  %w(
  rh-git29-git
  unzip
  python27
  rh-nodejs8
  rh-nodejs4
  libxslt-devel
  libxml2-devel
  devtoolset-6-gcc
  java-1.8.0-openjdk
  java-1.8.0-openjdk-devel
  java-1.7.0-openjdk
  java-1.7.0-openjdk-devel
  oracle-instantclient12.2-basic
  oracle-instantclient12.2-devel
  ).each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end

  # check if strong-pm log location exist
  describe file('/var/lib/jenkins') do
    it { should exist }
    it { should be_directory }
    its('owner') { should eq 'jenkins' }
  end

  describe file('/home/jenkins/.ssh') do
    it { should exist }
    it { should be_directory }
    its('owner') { should eq 'jenkins' }
    its('group') { should be 'jenkins'}
    its('mode') { should cmp '0755' }
  end

  describe file('/home/jenkins/.ssh/authorized_keys') do
    it { should exist }
    it { should be_file }
    its('owner') { should eq 'jenkins' }
    its('group') { should be 'jenkins'}
    its('mode') { should cmp '0600' }
  end

  describe file('/opt/apache/apache-maven-3.5.0/bin/mvn') do
    it { should exist }
    it { should be_file }
    its('owner') { should eq 'jenkins' }
    its('group') { should be 'jenkins'}
  end

  describe file('/opt/apache/apache-jmeter-3.3/bin/jmeter') do
    it { should exist }
    it { should be_file }
    its('owner') { should eq 'jenkins' }
    its('group') { should be 'jenkins'}
  end

  describe file('/etc/profile.d/rh-git29.sh') do
    it { should be_symlink }
  end

  describe file('/etc/profile.d/devtoolset-6.sh') do
    it { should be_symlink }
  end

  describe file('/home/jenkins/.config/pip/pip.conf') do
    it { should exist }
    it { should be_file }
    its('owner') { should eq 'jenkins' }
    its('group') { should be 'jenkins' }
  end

  describe file('/opt/parasoft/soatest/9.10/localsettings.properties') do
    it { should exist }
    it { should be_file }
    its('owner') { should eq 'jenkins' }
    its('group') { should be 'jenkins' }
  end

  describe file('/opt/rh/rh-nodejs4/root/usr/etc/npmrc') do
    it { should exist }
    it { should be_file }
    its('owner') { should eq 'root' }
    its('group') { should be 'root' }
  end

  describe file('/opt/rh/rh-nodejs8/root/usr/etc/npmrc') do
    it { should exist }
    it { should be_file }
    its('owner') { should eq 'root' }
    its('group') { should be 'root' }
  end

  if (grains['jenkins']['slave']['cjoc']) then
    describe file('/var/lib/jenkins') do
      it { should exist }
      it { should be_directory }
      its('owner') { should eq 'jenkins' }
      its('group') { should be 'jenkins' }
      its('mode') { should cmp '0755' }
    end

    describe file('/var/lib/jenkins/bin/slave.jar') do
      it { should exist }
      it { should be_file }
    end

    describe file('/var/cache/jenkins/jenkins-cli.jar') do
      it { should exist }
      it { should be_file }
    end
  end

  describe port(22) do
    it { should be_listening }
  end  
end