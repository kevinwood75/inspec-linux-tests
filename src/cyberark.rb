control "cyberark-1.0" do
  impact 1.0
  title 'cyberark'
  desc "Validate cyberark installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat'
  end

  describe group('cpvuser') do
    it { should exist }
    it { should have_gid 3700 }
  end

  describe user('cpvroot') do
    it { should exist }
    its('group') { should eq 'cpvuser' }
    its('uid') { should eq 117930 }
    its('shell') { should eq '/bin/bash' }
    its('home') { should eq '/home/cpvroot' }
  end

  describe file('/etc/shadow') do
  	it { should exist }
  	its('content') { should match(%r{cpvroot:\*}) }
  end

  describe file('/home/cpvroot/.ssh/authorized_keys') do
  	it { should exist }
  	its('content') { should match(%r{ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAlDX7lBfEr3lnBX95aarDwzV39k\+kCz6BabkiRJ9RH1/Pz2lfg0kT0YMJeZHGxZAT88slvUg\+2xWjm9C2tDd6iT\+qXLLAIIgiw/2/9x7GL7hZKVk7UwVSeiwf/vQOOO1HhH3gdJjIJyqs3IXa0cn86Jm\+AZZTT\+PiNuVKZuaoq3Iggqj5YKZEjhRyJqMDGcOPEny3lbeDFe\+vplDJx\+iS5budafKGlfhTcf993jeoTQIN90X4lfhZmAHiy2ZsHPNlgWWFN\+PUyZMc79zrAUw5UbZ65NJRPe43uq9JQDESqj9PRLD8PuxPeOsPG8QLWhDBWodBczUNNNWmr/cjer6XCw==}) }
  end

  describe file('/etc/profile.d/zzzcyberark-fix.sh') do
    it { should exist }
    its('md5sum') { should eq '4e860b2062f64c40a16507f6e7bbb923' }
  end
end  
