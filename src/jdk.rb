control "jdk-1.0" do
  impact 1.0
  title 'jdk'
  desc "Validate jdk installation"

  jdk_roles = ["jboss.eap",
               "jboss.ews.apache",
               "rundeckpro",
               "jenkins",
               "jenkins-elasticsearch",
               "jenkins-slave-openstack"]

  params = salt_info
  grains = params.grains
  pillar = params.pillar
  
  only_if do
    grains['os_family'] == 'RedHat' and not (grains['roles'] & jdk_roles).empty?
  end

  jdk_pkg_dev = pillar['jdk']['lookup']['pkg'] + '-devel'

  describe package(pillar['jdk']['lookup']['pkg']) do
    it { should be_installed }
  end

  describe package(jdk_pkg_dev) do
    it { should be_installed }
  end
end
