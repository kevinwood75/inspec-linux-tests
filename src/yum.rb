control "yum-1.0" do
  impact 1.0
  title 'yum'
  desc "Validate YUM package installation"

  params = salt_info
  grains = params.grains
  pillar = params.pillar

  only_if do
    grains['os_family'] == 'RedHat'
  end

  describe package('yum') do
    it { should be_installed }
  end

  describe package('yum-utils') do
    it { should be_installed }
  end

  describe file('/etc/yum.conf') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('content') { should match(%r{plugins = 1}) }
    its('content') { should match(%r{keepcache = 0}) }
    its('content') { should match(%r{cachedir = /var/cache/yum/\$basearch/\$releasever}) }
    its('content') { should match(%r{exactarch = 1}) }
    its('content') { should match(%r{obsoletes = 1}) }
    its('content') { should match(%r{installonly_limit = 2}) }
    its('content') { should match(%r{debuglevel = 2}) }
    its('content') { should match(%r{gpgcheck = 1}) }
    its('content') { should match(%r{logfile = /var/log/yum.log}) }
  end

  describe file('/boot') do
    it { should_not be_mounted }
  end

  if grains['osrelease'].start_with?('6')
    baseurl = pillar['yum']['repo']['nexus']['mirrorurl'] 

    if baseurl == nil
      baseurl = 'http://nexus.mgmt1.cloud.td.com/nexus/content/groups/ITS-Group'
    end

    describe command('yum-config-manager nexus') do
      its('exit_status') { should eq 0 }
      its('stdout') { should match(%r{baseurl = #{baseurl}}) }
      its('stdout') { should match(%r{enabled = #{pillar['yum']['repo']['nexus']['enable'] ? 'True': 'False'}}) }
      its('stdout') { should match(%r{gpgcheck = #{pillar['yum']['repo']['nexus']['gpgcheck'] ? 'True': 'False'}}) }
      its('stdout') { should match(%r{metadata_expire = 30}) }
    end
  end

  rpm_gpg_keys = %w(
      RPM-GPG-KEY-redhat-release
      RPM-GPG-KEY-TD
      RPM-GPG-KEY-TD-CLOUD
      RPM-GPG-KEY-SALTSTACK
      RPM-GPG-KEY-SPLUNK
      RPM-GPG-KEY-Mongodb32-Enterprise
   )
   
  # pillar['rpm_gpg_keys']['gpg_keys'].each do |gpg_key|
  rpm_gpg_keys.each do |gpg_key|
    keyfile = File.join(pillar['yum']['rpm_gpg_keys']['dir'], gpg_key) 

    describe file(keyfile) do
      it { should exist }
      it { should be_file }
      it { should be_mode 0644 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end

    describe command('KEYFILE='+keyfile+'; KEYID=$(echo $(gpg --throw-keyids < $KEYFILE)|cut -c11-18|tr [A-Z] [a-z]); rpm -qa |grep gpg-pubkey-$KEYID') do
       its('stdout') { should match /gpg-pubkey-/ }
    end
  end
end

control "yum_remi-1.0" do
  impact 1.0
  title 'yum_remi'
  desc 'Validate Redis repo configuration'

  params = salt_info
  grains = params.grains
  pillar = params.pillar
  
  only_if do
    grains['os_family'] == 'RedHat' && grains['roles'].include?('redis')
  end

  baseurl = pillar['repo']['remi']['mirrorurl'] || 'http://rpms.famillecollet.com/enterprise/\$releaseserver/remi/x86_64/'

  describe command('yum-config-manager remi') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(%r{baseurl = #{baseurl}}) }
    its('stdout') { should match(%r{enabled = True}) }
    its('stdout') { should match(%r{gpgcheck = #{pillar['repo']['remi']['gpgcheck'] ? 'True': 'False'}}) }
  end
end

