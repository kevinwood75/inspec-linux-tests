control "jenkins_elasticsearch-1.0" do
  impact 1.0
  title 'jenkins'
  desc "Validate jenkins elasticsearch installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'jenkins-elasticsearch'
  end

  describe package('elasticsearch') do
    it { should be_installed }
  end
  
  describe service('elasticsearch') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(9200) do
    it { should be_listening }
  end  
end