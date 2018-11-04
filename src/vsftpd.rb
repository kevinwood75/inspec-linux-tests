control "vsftpd-1.0" do
  impact 1.0
  title 'vsftpd'
  desc "Validate vsftpd installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'vsftpd'
  end

  describe package('vsftpd') do
    it { should be_installed }
  end
  
  describe service('vsftpd') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/etc/vsftpd/vsftpd.conf') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'root'}
    its('group') { should eq 'root' }
    # md5sum check since the file created via macros rather than changable values
    its('md5sum') { should eq '80350c90f9ec69693d8198a11433f936' }
  end
  
  describe port(990) do
    it { should be_listening }
  end
end
