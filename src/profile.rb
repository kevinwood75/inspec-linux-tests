control "profile-1.0" do
  impact 1.0
  title 'profile'
  desc "Validate profile installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat'
  end

  describe file('/etc/profile') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0644' }
  end

  describe file('/etc/profile.d') do
    it { should exist }
    it { should be_directory }
    its('mode') { should cmp '0755' }
  end

  describe file('/etc/profile.d/bash_history_timestamp.sh') do
    it { should exist }
    it { should be_file }
    its('md5sum') { should eq '5f4218abd1c6d8b0dc98b47deac34084' }
    its('mode') { should cmp '0644' }
  end

  describe file('/etc/profile.d/256_colour_term.sh') do
    it { should exist }
    it { should be_file }
    its('md5sum') { should eq 'ddd40de4831e3754937c51dafe53a82c' }
    its('mode') { should cmp '0644' }
  end

  describe file('/etc/profile.d/ksh.sh') do
    it { should exist }
    it { should be_file }
    its('md5sum') { should eq '580febeac3ccb7d4f3b1dca66a3ccf2a' }
    its('mode') { should cmp '0644' }
  end
end
