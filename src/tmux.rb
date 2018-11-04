control "tmux-1.0" do
  impact 1.0
  title 'tmux'
  desc "Validate tmux installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'jboss.jon.client'
  end

  describe package('tmux') do
    it { should be_installed }
  end

  describe file('/etc/tmux.conf') do
    it { should exist }
    it { should be_file }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('md5sum') { should eq 'e8ceb05beee462b9c0bfde9295c5429b' }
  end
end