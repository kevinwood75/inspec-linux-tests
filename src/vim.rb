control "vim-1.0" do
  impact 1.0
  title 'vim'
  desc "Validate vim installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat'
  end

# tests pass on both rhel6 and 7 as-is  
  describe file('/usr/share/vim/vimfiles/ftdetect/sls.vim') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'root' }
    its('group') { should eq  'root' }
    its('md5sum') { should eq 'ae010f03ce383b704f89d37fde7b16d0' }
  end
  
  describe file('/usr/share/vim/vimfiles/ftplugin/sls.vim') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'root' }
    its('group') { should eq  'root' }
    its('md5sum') { should eq '6f020d2f8a5e9a36c403ed6d8992758c' }
  end
  
  describe file('/usr/share/vim/vimfiles/syntax/sls.vim') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'root' }
    its('group') { should eq  'root' }
    its('md5sum') { should eq 'f08d21366270ec205047f1cf49191314' }
  end
  
  describe file('/usr/share/vim/vimfiles/syntax/yaml.vim') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'root' }
    its('group') { should eq  'root' }
    its('md5sum') { should eq '5ad8e59d1ef45a1c71748168ea5f53fd' }
  end
  
  describe file('/etc/vimrc') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'root' }
    its('group') { should eq  'root' }
    its('md5sum') { should eq '6de58c4248d2014bf803111d39dd46c4' }
  end
end