control "krb5-1.0" do
  impact 1.0
  title 'krb5'
  desc "Validate krb5 installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['active_directory_joined']
  end

  describe package('krb5-libs') do
    it { should be_installed }
  end

  if (grains['environment'] == 'dev' or grains['environment'] == 'sit') then
    content_to_check = 'D2-TDBFG.COM'
  elsif (grains['environment'] == 'pat') then
    content_to_check = 'P-TDBFG.COM'
  elsif (grains['environment'] == 'prod') then
    content_to_check = ' TDBFG.COM'
  end
  
  describe file('/etc/krb5.conf') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('content') { should match /#{content_to_check}/ }
    its('content') { should match /# This file is managed by salt\. Manual changes risk being overwritten\./ }
  end
end