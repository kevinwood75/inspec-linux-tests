control "websphere-1.0" do
  impact 1.0
  title 'websphere'
  desc "Validate websphere installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'websphere'
  end

  td_repository_home = grains['IBM']['td_repository_home'] ||= 'http://nexus01.mgmt1.cloud.td.com/nexus/content/repositories/WebsphereND'
  im = grains['IBM']['InstallationManager']
  if im
    im_home = im['home'] ||= '/usr/opt/InstallationManager'
  else
    im_home = '/usr/opt/InstallationManager'
  end
  was_admin_user = grains['IBM']['WebSphere']['was_admin_user'] ||= 'wasadm'
  was_admin_group = grains['IBM']['WebSphere']['was_admin_group'] ||= 'wasadm'
  was_support_user = grains['IBM']['WebSphere']['was_support_user'] ||= 'wassup'
  was_support_group = grains['IBM']['WebSphere']['was_support_group'] ||= 'wassup'
  cell_name = grains['IBM']['WebSphere']['Cell']['name']
  environment = grains['IBM']['WebSphere']['Cell']['environment'].sub('AD_', '')
  dmgr = grains['IBM']['WebSphere']['Node']['dmgr']
  appserver = grains['IBM']['WebSphere']['Node']['appserver']
  webserver = grains['IBM']['WebSphere']['Node']['webserver']
  external_host_name = grains['IBM']['WebSphere']['Node']['external_host_name']
  internal_host_name = grains['IBM']['WebSphere']['Node']['internal_host_name']

  # short_name = Socket.gethostname[/^[^.]+/]
  short_name = grains['instance_id']

  if dmgr || appserver
    was_home = grains['IBM']['WebSphere']['Node']['was_home'] ||= '/usr/opt/WebSphere/AppServer'
    nd_version = grains['IBM']['WebSphere']['ND']['version']
    nd_fixpack = grains['IBM']['WebSphere']['ND']['fixpack'].to_s.rjust(2, '0')
    nd_binaries = []
    nd_url = URI.parse("#{td_repository_home}/input_files/install_was_#{nd_version}.#{nd_fixpack}.xml")
    nd_req = Net::HTTP::Get.new(nd_url.to_s)
    nd_res = Net::HTTP.start(nd_url.host, nd_url.port) { |http| http.request(nd_req) }
    nd_doc = REXML::Document.new nd_res.body
    nd_doc.elements.each('agent-input/install/offering') { |element| nd_binaries.push(element.attributes) }
    starting_port = grains['IBM']['WebSphere']['Node']['starting_porta'] ||= 19000
    ending_port = starting_port + 999
    dmgr_https_port = starting_port + 1
    dmgr_soap_port = starting_port + 3
    nodeagent_soap_port = starting_port + 59
  end

  if webserver
    ihs_admin_group = grains['IBM']['WebSphere']['ihs_admin_group'] ||= 'ihsgroup'
    plg_home = grains['IBM']['WebSphere']['Node']['plg_home'] ||= '/usr/opt/WebSphere/Plugins'
    plg_version = grains['IBM']['WebSphere']['PLG']['version']
    plg_fixpack = grains['IBM']['WebSphere']['PLG']['fixpack'].to_s.rjust(2, '0')
    plg_binaries = []
    plg_url = URI.parse("#{td_repository_home}/input_files/install_plg_#{plg_version}.#{plg_fixpack}.xml")
    plg_req = Net::HTTP::Get.new(plg_url.to_s)
    plg_res = Net::HTTP.start(plg_url.host, plg_url.port) { |http| http.request(plg_req) }
    plg_doc = REXML::Document.new plg_res.body
    plg_doc.elements.each('agent-input/install/offering') { |element| plg_binaries.push(element.attributes) }
    ihs_home = grains['IBM']['WebSphere']['Node']['ihs_home'] ||= '/usr/opt/HTTPServer'
    ihs_version = grains['IBM']['WebSphere']['IHS']['version']
    ihs_fixpack = grains['IBM']['WebSphere']['IHS']['fixpack'].to_s.rjust(2, '0')
    ihs_binaries = []
    ihs_url = URI.parse("#{td_repository_home}/input_files/install_ihs_#{ihs_version}.#{ihs_fixpack}.xml")
    ihs_req = Net::HTTP::Get.new(ihs_url.to_s)
    ihs_res = Net::HTTP.start(ihs_url.host, ihs_url.port) { |http| http.request(ihs_req) }
    ihs_doc = REXML::Document.new ihs_res.body
    ihs_doc.elements.each('agent-input/install/offering') { |element| ihs_binaries.push(element.attributes) }
    web_server_ports = grains['IBM']['WebSphere']['Node']['web_server_ports'] ||= ['443']
    ihs_instance = "ihs_#{short_name}"
  end

  #-------------------------------------------------------------------
  # hosts resolvable
  #
  describe host(external_host_name) do
    it { should be_resolvable }
  end

  describe host(internal_host_name) do
    it { should be_resolvable }
  end

  #-------------------------------------------------------------------
  # users/groups
  #
  describe group(was_admin_group) do
    it { should exist }
  end

  describe group(was_support_group) do
    it { should exist }
  end

  if webserver
    describe group(ihs_admin_group) do
      it { should exist }
    end
  end

  describe user(was_admin_user) do
    it { should exist }
    its('group') { should eq was_admin_group }
    its('groups') { should include was_support_group }
    if webserver
    	its('groups') { should include ihs_admin_group }
    end
  end

  describe user(was_support_user) do
    it { should exist }
    its('group') { should eq was_admin_group }
    its('groups') { should include was_support_group }
    if webserver
    	its('groups') { should include ihs_admin_group }
    end
  end

  #-------------------------------------------------------------------
  # cron
  #
  describe crontab.commands('/usr/sbin/websphere.logrotate.cron') do
    its('minutes') { should cmp '0,10,20,30,40,50' }
    its('hours') { should cmp '*' }
    its('days') { should cmp '*' }
    its('months') { should cmp '*' }
  end

  #-------------------------------------------------------------------
  # sysctl
  #
  describe command('sysctl -a') do
    its('stdout') { should match /net\.ipv4\.tcp_keepalive_time = 90/ }
    its('stdout') { should match /net\.ipv4\.tcp_keepalive_probes = 6/ }
    its('stdout') { should match /net\.ipv4\.tcp_keepalive_intvl = 5/ }
  end

  #-------------------------------------------------------------------
  # binaries/ibm im
  #
  describe command("su - wasadm \"-c #{im_home}/eclipse/tools/imcl listInstalledPackages\"") do
    its('stdout') { should match /com\.ibm\.cic\.agent_/ }
    if dmgr || appserver
      nd_binaries.each do |nd_binary|
        if nd_binary['version']
          its('stdout') { should match /#{nd_binary['id']}_#{nd_binary['version']}/ }
        else
          its('stdout') { should match /#{nd_binary['id']}/ }
        end
      end
    end
    if webserver
      plg_binaries.each do |plg_binary|
        if plg_binary['version']
          its('stdout') { should match /#{plg_binary['id']}_#{plg_binary['version']}/ }
        else
          its('stdout') { should match /#{plg_binary['id']}/ }
        end
      end
      ihs_binaries.each do |ihs_binary|
        if ihs_binary['version']
          its('stdout') { should match /#{ihs_binary['id']}_#{ihs_binary['version']}/ }
        else
          its('stdout') { should match /#{ihs_binary['id']}/ }
        end
      end
    end
  end

  #-------------------------------------------------------------------
  # profiles
  #
  if dmgr
    describe file("#{was_home}/profiles/#{dmgr}") do
      it { should exist }
      it { should be_directory }
      its('owner') { should eq was_admin_user }
    end
  end

  if appserver
    describe file("#{was_home}/profiles/#{appserver}") do
      it { should exist }
      it { should be_directory }
      its('owner') { should eq was_admin_user }
    end
  end

  if webserver
    describe file("#{plg_home}/config/#{ihs_instance}") do
    	it { should exist }
    	it { should be_directory }
    end

    describe file("#{plg_home}/config/#{ihs_instance}/plugin-cfg.xml") do
    	it { should exist }
    	it { should be_file }
    end

    describe file("#{plg_home}/config/#{ihs_instance}/plugin-key.kdb") do
    	it { should exist }
    	it { should be_file }
    end

    describe file("#{plg_home}/config/#{ihs_instance}/plugin-key.sth") do
    	it { should exist }
    	it { should be_file }
    end

    describe file("#{ihs_home}/conf/admin.conf") do
    	it { should exist }
    	it { should be_file }
    end

    describe file("#{ihs_home}/conf/#{ihs_instance}_httpd.conf") do
    	it { should exist }
    	it { should be_file }
    end

    describe file("#{ihs_home}/conf/#{ihs_instance}_vhosts") do
    	it { should exist }
    	it { should be_directory }
    end

    web_server_ports.each do |web_server_port|
      describe file("#{ihs_home}/conf/#{ihs_instance}_vhosts/#{web_server_port}_vhost.conf") do
        it { should exist }
        it { should be_file }
      end
    end
  end

  #-------------------------------------------------------------------
  # console identity
  #
  if dmgr
    describe file("#{was_home}/profiles/#{dmgr}/config/cells/#{cell_name}/applications/isclite.ear/deployments/isclite/isclite.war/WEB-INF/consoleProperties.xml") do
    	it { should exist }
    	its('content') { should match /THIS IS #{environment}/ }
    end
  end

  #-------------------------------------------------------------------
  # services enabled
  #
  if dmgr then
    describe service('websphere_dmgr_was.init') do
    	it { should be_enabled }
    end
  end

  if appserver
    describe service('websphere_nodeagent_was.init') do
      it { should be_enabled }
    end
  end

  if webserver
    describe service('ihs_admin.init') do
      it { should be_enabled }
    end

    describe service("#{ihs_instance}.init") do
      it { should be_enabled }
    end
  end

  #-------------------------------------------------------------------
  # ports listening
  #
  if dmgr
    describe port(dmgr_https_port) do
      it { should be_listening }
    end

    describe port(dmgr_soap_port) do
      it { should be_listening }
    end
  end

  if appserver
    describe port(nodeagent_soap_port) do
      it { should be_listening }
    end
  end

  if webserver
    describe port(8008) do
      it { should be_listening }
    end

    web_server_ports.each do |web_server_port|
      describe port(web_server_port) do
        it { should be_listening }
      end
    end
  end
end