control "strongloop-1.0" do
  impact 1.0
  title 'strongloop'
  desc "Validate strongloop installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'strongpm'
  end

  # firewall should NOT have port 8701 open, this is a change and only have port range 3000:3100 open
  #describe command('iptables-save | grep ACCEPT') do
  #  its(:stdout) { should contain ('3000')}
  #  its(:stdout) { should contain ('3100')}
  #  its(:stdout) { should_not contain ('8701')}
  #end

  describe user('nodejs') do
  	it { should exist }
  end

  describe user('strong-pm') do
  	it { should exist }
  	# its('groups') { should cmp 'nodejs' }
  end

  # check if strong-pm log location exist
  describe file('/var/log/strongloop') do
    it { should exist }
    it { should be_directory }
    its('owner') { should eq 'strong-pm' }
  end

  # check if post-install-script log exist
  #describe file('/var/tmp/post-install-script.log') do
  #  it { should exist }
  #  it { should be_file }
  #  its('mode') { should cmp '0644' }
  #end

  # Check that the strong-pm.service is running and enabled
  if grains['osrelease'].start_with? ('7')
    describe service('strong-pm.service') do
      it { should be_enabled }
      it { should be_running }
    end
  else
    describe service('strong-pm') do
      #it { should be_enabled }
      it { should be_running }
    end
  end

  describe port(3000) do
  	it { should be_listening }
  end

  #Check valid response from a deployed service 
  describe command('curl http://localhost:3000') do
  	its('exit_status') { should eq 0 }
    its('stdout') { should match /HELLO/ }
  end

  # Run specific set of tests for the rh-nodejs install
  nodejs_package = grains['nodejs_package']

  if nodejs_package and nodejs_package.include? 'rh-nodejs4'
    describe command('source scl_source enable rh-nodejs4 ;sl-pmctl -C http://admin:admin@localhost:8701 status 1') do
      its('stdout') { should match /API_CONFIG/ }
      its('stdout') { should match /SHARED_CONFIG/ }
      its('stdout') { should match /LOG_LOCATION/ }
      its('stdout') { should match /PORT/ }
      its('stdout') { should match /30[08][0-9]/ }
    end

    # Check version of nodejs
    describe command('source scl_source enable rh-nodejs4 ; node --version') do
      its('stdout') { should match /v4\./ }
    end

    # Check that the rh-nodejs4 package is installed
    describe package('rh-nodejs4') do
      it { should be_installed }
    end

    unless grains['npm_version'].nil?
      # Check version of npm
      describe command('source scl_source enable rh-nodejs4 ;npm --version') do
        its('stdout') { should match /#{grains['npm_version']}/ }
      end
    end

    # Check version of strongpm-deploy
    describe command('source scl_source enable rh-nodejs4 ;sl-deploy --version') do
      its('stdout') { should match /#{grains['strongloop']['strong-pm-deploy_version']}/ }
    end

    # Check version of strongpm-supervisor
    describe command('source scl_source enable rh-nodejs4 ;sl-runctl --version') do
      its('stdout') { should match /#{grains['strongloop']['strong-pm-supervisor_version']}/ }
    end

    # Check version of strong-pm
    describe command('source scl_source enable rh-nodejs4 ;sl-pm --version') do
      its('stdout') { should match /#{grains['strongloop']['strong-pm_version']}/ }
    end
  end

  # Run specific set of tests for the rh-nodejs6 install
  if nodejs_package and nodejs_package.include? 'rh-nodejs6'

    describe command('source scl_source enable rh-nodejs6 ;sl-pmctl -C http://admin:admin@localhost:8701 status 1') do
      its('stdout') { should match /API_CONFIG/ }
      its('stdout') { should match /SHARED_CONFIG/ }
      its('stdout') { should match /LOG_LOCATION/ }
      its('stdout') { should match /PORT/ }
      its('stdout') { should match /30[08][0-9]/ }
    end

    # Check version of nodejs
    describe command('source scl_source enable rh-nodejs6 ;node --version') do
      its('stdout') { should match /v6\./ }
    end

    # Check that the rh-nodejs6 package is installed
    describe package('rh-nodejs6') do
      it { should be_installed }
    end

    unless grains['npm_version'].nil?
      # Check version of npm
      describe command('source scl_source enable rh-nodejs6 ;npm --version') do
        its('stdout') { should match /#{grains['npm_version']}/ }
      end
    end

    # Check version of strongpm-deploy
    describe command('source scl_source enable rh-nodejs6 ;sl-deploy --version') do
      its('stdout') { should match /#{grains['strongloop']['strong-pm-deploy_version']}/ }
    end

    # Check version of strongpm-supervisor
    describe command('source scl_source enable rh-nodejs6 ;sl-runctl --version') do
      its('stdout') { should match /#{grains['strongloop']['strong-pm-supervisor_version']}/ }
    end

    # Check version of strong-pm
    describe command('source scl_source enable rh-nodejs6 ;sl-pm --version') do
      its('stdout') { should match /#{grains['strongloop']['strong-pm_version']}/ }
    end
  end
end