control "sudoers-1.0" do
  impact 1.0
  title 'sudoers'
  desc "Validate sudoers installation"

  params = salt_info
  grains = params.grains
  pillar = params.pillar
  
  only_if do
    grains['os_family'] == 'RedHat'
  end

  describe package('sudo') do
    it { should be_installed }
  end

  describe file('/etc/sudoers') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0440' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('content') { should match /# This file is managed by salt/ }
    its('content') { should match /root ALL=\(ALL\) NOPASSWD: ALL/ } # text value sourced from pillar/sudoers/sudoers.sls
  end

  pillar['sudoers']['included_files'].each do |fname, val|
  	describe file(fname) do
      it { should exist }
      it { should be_file }
      its('mode') { should cmp '0440' }
      its('owner') { should eq 'root' }
      its('group') { should eq 'root' }
  	end
  end
end
