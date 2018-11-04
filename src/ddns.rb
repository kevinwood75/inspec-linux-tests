control "ddns-1.0" do
  impact 1.0
  title 'ddns'
  desc "Validate ddns installation"

  params = salt_info
  grains = params.grains
  pillar = params.pillar

  only_if do
    grains['os_family'] == 'RedHat'
  end

  describe package('python-dns') do
    it { should be_installed }
  end

  describe package('bind-utils') do
    it { should be_installed }
  end

  inspec.command('bash -c "ls /etc/nsupdate_*script*"').stdout.split("\n").each do |fname|	
    describe file(fname) do
      it { should exist }
      it { should be_file }
      its('mode') { should cmp '0600'}
    end
  end
  
  describe host(pillar['dns']['tenant_fqdn']) do
    it { should be_resolvable }
    its('ipaddress') { should include grains['ipv4'][0] }
  end

  # Dynamic FQDN and Tenant FQDN IPs are set to Private_IP_Address for EWS and Websphere VMs
  ip = (grains['roles'] & ['websphere_nd', 'jboss.ews.apache', 'websphere'] == []) ? grains['floating_ip_address'] : grains['ipv4'][0]
  describe host(pillar['dns']['dynamic_fqdn']) do
    it { should be_resolvable }
    its('ipaddress') { should include ip }
  end
end
