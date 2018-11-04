control "rhn_satellite-1.1" do
  impact 1.1
  title 'rhn_satellite'
  desc "Validate rhn_satellite installation"

  params = salt_info
  grains = params.grains
  pillar = params.pillar

  satellite6_proxy = { "VIRGINIA" => "capsule02.rackspace-mgmt.cloud.td.com",
                        "BDC" => "capsule01.mgmt1.cloud.td.com", 
                        "SOC" => "capsule03.mgmt2.cloud.td.com" }

  satellite5_proxy = { "VIRGINIA" => "rhnsatellite-proxy.rackspace-mgmt.cloud.td.com",
                        "BDC" => "rhnsatellite01.mgmt1.cloud.tdbank.ca",
                        "SOC" => "rhnsatellite01.mgmt1.cloud.tdbank.ca" } 
  only_if do
    grains['os_family'] == 'RedHat' and not grains['roles'].include?('rhn_satellite_server') and not grains['roles'].include?('rhn_satellite_proxy')
  end

  if grains['use_rhsm'] == true or pillar['rhn_satellite']['client']['use_rhsm'] == true
    # Satellite 6, RHSM
    pkgs = ['katello-agent', 'gofer']
    services = ['goferd']
    cmd = 'subscription-manager status | grep -qw Status:.*Current'
    proxy_url = pillar['rhn_satellite']['client']['satellite6_client_package_url']
    datacenter = pillar['datacenters']['current']['name']
    proxy_in_datacenter = satellite6_proxy[datacenter]
  else
    # Satellite 5, RHN Classic
    pkgs = ['rhn-setup']
    services = ['rhnsd']
    cmd = '/usr/sbin/rhn_check'
    proxy_url = pillar['rhn_satellite']['client']['proxy_server_url5']
    datacenter = pillar['datacenters']['current']['name']
    proxy_in_datacenter = satellite5_proxy[datacenter]
  end

  pkgs.each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end

  services.each do |service|
    describe service(service) do
      it { should be_enabled }
      it { should be_running }
    end
  end

  describe command(cmd) do
  	its('exit_status') { should eq 0 }
  end

  describe proxy_url do
     it { should include proxy_in_datacenter  }
  end
end
