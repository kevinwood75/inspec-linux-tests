control "jenkins-1.0" do
  impact 1.0
  title 'jenkins'
  desc "Validate jenkins installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'jenkins'
  end

  jenkins_env = grains['jenkins_environment'] == 'jenkins-oc' ? 'jenkins-oc' : 'jenkins'

  describe package(jenkins_env) do
    it { should be_installed }
  end

  describe service(jenkins_env) do
    it { should be_enabled }
    it { should be_running }
  end

  describe package('nginx') do
    it { should be_installed }
  end

  describe service('nginx') do
    it { should be_enabled }
    it { should be_running }
  end

  describe user(jenkins_env) do
    it { should exist }
    its('group') { should eq jenkins_env }
    its('home') { should eq File.join('/home', jenkins_env) }
  end

  describe group(jenkins_env) do
    it { should exist }
  end

  unless jenkins_env.eql? 'jenkins-oc'
    %w(python27 rh-nodejs4 libxslt-devel libxml2-devel).each do |pkg|
      describe package(pkg) do
        it { should be_installed }
      end
    end
  end

  %w(rh-git29-git unzip).each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end

  # Conf
  describe file('/etc/sysconfig/' + jenkins_env) do
    it { should exist }
    it { should be_file }
    its('owner') { should eq jenkins_env }
    its('group') { should eq jenkins_env }
    its('mode') { should cmp '0600' }

    pattern1 = ".*-Dhudson\.TcpSlaveAgentListener\.hostName=.*"
    pattern2 = ".*-Djenkins\.model\.Jenkins\.slaveAgentPort=50000.*"
    pattern3 = ".*-Dhudson\.model\.DownloadService\.noSignatureCheck=true.*"
    its('content') { should match /#{pattern1}/ }
    its('content') { should match /#{pattern2}/ }
    its('content') { should match /#{pattern3}/ }
  end

  describe file(File.join('/home', jenkins_env, '.ssh')) do
    it { should exist }
    it { should be_directory }
    its('owner') { should eq jenkins_env }
    its('group') { should eq jenkins_env }
    its('mode') { should cmp '0755' }
  end

  describe file(File.join('/home', jenkins_env, '.ssh', 'id_rsa')) do
    it { should exist }
    it { should be_file }
    its('owner') { should eq jenkins_env }
    its('group') { should eq jenkins_env }
    its('mode') { should cmp '0600' }
  end

  describe file(File.join('/home', jenkins_env, '.ssh', 'id_rsa.pub')) do
    it { should exist }
    it { should be_file }
    its('owner') { should eq jenkins_env }
    its('group') { should eq jenkins_env }
    its('mode') { should cmp '0644' }
  end

  describe file(File.join('/var', 'cache', jenkins_env, 'jenkins-cli.jar')) do
    it { should exist }
    it { should be_file }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
  end

  describe file(File.join('/usr', 'local', 'bin', 'jenkins-cli.sh')) do
    it { should exist }
    it { should be_file }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0700' }
  end

  if jenkins_env.eql? 'jenkins-oc' then
    describe file(File.join('/var', 'lib', jenkins_env, 'secret.key')) do
      it { should exist }
      it { should be_file }
      its('owner') { should eq jenkins_env }
      its('group') { should eq jenkins_env }
      its('mode') { should cmp '0644' }
    end

    describe file(File.join('/var', 'lib', jenkins_env, 'license.xml')) do
      it { should exist }
      it { should be_file }
      its('owner') { should eq jenkins_env }
      its('group') { should eq jenkins_env }
      its('mode') { should cmp '0644' }
    end
  end

  describe port(80) do
    it { should be_listening }
  end

  describe port(jenkins_env.eql?('jenkins-oc') ? 8888 : 8080) do
    it { should be_listening }
  end

  describe port(50000) do
    it { should be_listening }
  end
end
