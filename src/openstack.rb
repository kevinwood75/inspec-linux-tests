control "openstack-1.0" do
  impact 1.0
  title 'openstack'
  desc "Validate openstack installation"

  params = salt_info
  grains = params.grains
  pillar = params.pillar
  
  only_if do
    grains['os_family'] == 'RedHat'
  end

  if grains['cloudname'].downcase.start_with? 'rackspace'
    if pillar['dns']['bind_zone'].downcase.start_with? 'c5-'
      cloudname = "cloud5" 
    else
      cloudname = "cloud0" 
    end
  else
    cloudname = grains['cloudname'] 
  end

  describe "when checking salt grain cloudname" do
    it { expect(cloudname).not_to be_empty }
    it { expect(cloudname).to start_with("cloud") }
  end

  if grains['provider_instance_id']
    openstack_uuid = grains['provider_instance_id']
  elsif grains['openstack_uid']
    openstack_uuid = grains['openstack_uid']
  elsif grains['external_id']
    openstack_uuid = grains['external_id']
  elsif grains['uuid']
    openstack_uuid = grains['uuid']
  end

  describe "when checking salt grains openstack_uuid" do
    it { expect(openstack_uuid).not_to be_empty }
    it { expect(openstack_uuid).to match(/^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$/) }
  end

  if grains['id']
    internal_hostname = grains['id']
  else
    internal_hostname = pillar['dns']['tenant_fqdn']
  end

  describe "when checking salt grains/pillars internal_hostname" do
    it { expect(internal_hostname).not_to be_empty }
    it { expect(internal_hostname).to end_with("cloud.td.com") }
  end

  if grains['external_vm_name']
    external_hostname = grains['external_vm_name']
  else
    external_hostname = pillar['dns']['dynamic_fqdn']
  end

  describe "when checking salt grains/pillars external_hostname" do
    it { expect(external_hostname).not_to be_empty }
    it { expect(external_hostname).to end_with("cloud.td.com") }
  end

  mal_code = grains['mal_code']
  describe "when checking salt grains mal_code" do
    it { expect(mal_code).not_to be_empty }
  end


  # GATHERING OPENSTACK DETAILS
  os_login_url = pillar['openstack'][cloudname]['api_endpoints']['identity']['v2']+'/tokens'
  describe "when checking openstack pillar for "+cloudname+" os_login_url" do
    it { expect(os_login_url).not_to be_empty }
    it { expect(os_login_url).to match(/https?:\/\/(www\.)?[-a-zA-Z0-9@:%_\+.~#?&\/=]{2,256}\.[a-z]{2,4}\b(\/[-a-zA-Z0-9@:%_\+.~#?&\/=]*)?/) }
  end

  os_metadata_url = pillar['openstack'][cloudname]['api_endpoints']['compute']['v3']+'/servers/'+openstack_uuid+'/metadata'
  describe "when checking openstack pillar for "+cloudname+" os_metadata_url" do
    it { expect(os_metadata_url).not_to be_empty }
    it { expect(os_metadata_url).to match(/https?:\/\/(www\.)?[-a-zA-Z0-9@:%_\+.~#?&\/=]{2,256}\.[a-z]{2,4}\b(\/[-a-zA-Z0-9@:%_\+.~#?&\/=]*)?/) }
  end

  os_username = pillar['openstack'][cloudname]['user']
  describe "when checking openstack pillar for "+cloudname+" os_username" do
    it { expect(os_username).not_to be_empty }
  end

  os_password = pillar['openstack'][cloudname]['password']
  describe "when checking openstack pillar for "+cloudname+" os_password" do
    it { expect(os_password).not_to be_empty }
  end

  #######################################################
  # PERFORMING OPENSTACK METADATA TEST VIA OPENSTACK API#
  #######################################################

  ############################
  ## LOGIN TO OPENSTACK API ##
  ############################
  loginURI = URI.parse(os_login_url)
  loginRequest = Net::HTTP::Post.new(loginURI, 'Content-Type' => 'application/json')
  loginRequest.body = {"auth"=>{"tenantName"=>"admin", "passwordCredentials"=>{"username"=>os_username, "password"=>os_password}}}.to_json
  loginHttp = Net::HTTP.new(loginURI.host, loginURI.port)
  loginHttp.use_ssl = (loginURI.scheme == "https")
  loginResponse = loginHttp.request(loginRequest)

  describe "when login request sent to Openstack API response" do
    it { expect(loginResponse.code).to eq "200" }
    it { expect(loginResponse.message).to eq "OK" }
    it { expect(loginResponse.body).to match /token/ }
  end

  loginResponseJSON = JSON.parse(loginResponse.body)
  os_token_id = loginResponseJSON['access']['token']['id']
  describe "when logged into OPenstack API Access:Token:id" do
    it { expect(os_token_id).not_to be_empty }
    #it { expect(os_token_id).to match(/^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$/) }
    # it { pp os_token_id }
  end

  ########################################
  ## CHECK SERVER METADATA IN OPENSTACK ##
  ########################################
  metadataURI = URI.parse(os_metadata_url)
  metadataRequest = Net::HTTP::Get.new(metadataURI, 'Content-Type' => 'application/json')
  metadataRequest.add_field("X-Auth-Token", os_token_id)
  metadataHttp = Net::HTTP.new(metadataURI.host, metadataURI.port)
  metadataHttp.use_ssl = (metadataURI.scheme == "https")
  metadataResponse = metadataHttp.request(metadataRequest)
  metadataResponseJSON = JSON.parse(metadataResponse.body)

  describe "when Get metadata request sent to Openstack API response" do
    it { expect(metadataResponse.code).to eq "200" }
    it { expect(metadataResponse.message).to eq "OK" }
    it { expect(metadataResponse.body).to match /metadata/ }
  end

  osInternalHostname = metadataResponseJSON['metadata']['internal_hostname']
  describe "when openstack metadata has been set internal_hostname: "+ osInternalHostname do
    it { expect(osInternalHostname).not_to be_empty }
    it { expect(osInternalHostname).to eq internal_hostname }
  end

  osExternalHostname = metadataResponseJSON['metadata']['external_hostname']
  describe "when openstack metadata has been set external_hostname: "+osExternalHostname do
    it { expect(osExternalHostname).not_to be_empty }
    it { expect(osExternalHostname).to eq external_hostname }
  end

  osMalCode = metadataResponseJSON['metadata']['mal_code']
  describe "when openstack metadata set mal_code: "+osMalCode do
    it { expect(osMalCode).not_to be_empty }
    it { expect(osMalCode).to eq mal_code }
  end
end