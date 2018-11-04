control "postfix-1.0" do
  impact 1.0
  title 'postfix'
  desc "Validate postfix installation"

  params = salt_info
  grains = params.grains
  pillar = params.pillar
  
  only_if do
    grains['os_family'] == 'RedHat'
  end

  describe package('postfix') do
    it { should be_installed }
  end

  describe service('postfix') do
    it { should_not be_enabled }
  end

  describe processes('postfix') do
  	its('users') { should_not cmp 'systemd' }
  	its('users') { should_not cmp 'supervisor' }
  end

  describe package('sendmail') do
    it { should be_installed }
  end

  describe service('sendmail') do
    it { should_not be_enabled }
  end

  describe processes('sendmail') do
  	its('users') { should_not cmp 'systemd' }
  	its('users') { should_not cmp 'supervisor' }
  end

  describe file('/etc/mail/submit.cf') do
    it { should exist }
    it { should be_file }
    its('content') { should match /D\{MTAHost\}\[#{pillar['postfix']['relayhost'][1..-2]}\]/ }
  end

  if grains['osrelease'].start_with?('6') and grains['roles'].include? 'relay'
    describe command('ss -tnlp4|grep -qE "127.0.0.1:(465|25).*master"') do
      its('exit_status') { should eq 1 }
    end
  end
end
