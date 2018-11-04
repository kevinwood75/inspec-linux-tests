control "jboss-ews-apache-1.0" do
  impact 1.0
  title 'jboss-ews-apache'
  desc "Validate jboss ews apache installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'jboss.ews.apache'
  end

  [80, 443, 8080].each do |p|
    describe port(p) do
      it { should be_listening }
    end
  end

  describe file('/etc/sudoers.d/37-jboss-ews') do
    it { should exist }
    it { should be_file }
    # Based on how the state is coded this is what would be expected, but in reality the file ends up owned by root and with a different mode
    # It appears some other process updates the file afterwards but it is not quite clear what process that is
    its('mode') { should cmp '0400' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
  end

  describe file('/etc/sudoers.d/91-support-groups') do
    it { should exist }
    it { should be_file }
    # Based on how the state is coded this is what would be expected, but in reality the file ends up owned by root and with a different mode
    # It appears some other process updates the file afterwards but it is not quite clear what process that is
    its('mode') { should cmp '0440' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
   end  
end

control "jboss-standalone-1.0" do
  impact 1.0
  title 'jboss-standalone'
  desc 'Validate jboss-standalone'

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'jboss.eap.standalone'
  end

  [8080, 8443, 8009, 9991].each do |p|
    describe port(p) do
      it { should be_listening }
    end
  end

  describe file('/etc/sudoers.d/37-jboss-eap') do
    it { should exist }
    it { should be_file }
    # Based on how the state is coded this is what would be expected, but in reality the file ends up owned by root and with a different mode
    # It appears some other process updates the file afterwards but it is not quite clear what process that is
    its('mode') { should cmp '0400' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
  end

  describe file('/etc/sudoers.d/91-support-groups') do
    it { should exist }
    it { should be_file }
    # Based on how the state is coded this is what would be expected, but in reality the file ends up owned by root and with a different mode
    # It appears some other process updates the file afterwards but it is not quite clear what process that is
    its('mode') { should cmp '0440' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
  end
end

control "jboss-standalone-jgroups-1.0" do
  impact 1.0
  title 'jboss-standalone-jgroups'
  desc 'Validate jboss-standalone-jgroups'

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'jboss.eap.standalone.jgroups'
  end

  # Commented because only clustered application deploys on EAP, port 7800 starts to listen. 
  # Our ITS certified Jboss BP doesn't have an application so port 7800 is not listening
  # describe port(7800) do
  #   it { should be_listening }
  # end
end
