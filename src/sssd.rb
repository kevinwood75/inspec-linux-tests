control "sssd-1.0" do
  impact 1.0
  title 'sssd'
  desc "Validate sssd installation"

  params = salt_info
  grains = params.grains
  pillar = params.pillar
  
  only_if do
    grains['os_family'] == 'RedHat' and (grains['active_directory_joined'] == 'True' or grains['active_directory_joined'] == true)
  end

  %w(sssd adcli sssd-ad sssd-krb5 sssd-ldap sssd-dbus sssd-proxy).each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end
  
  describe service('sssd') do
    it { should be_enabled }
    it { should be_running }
  end

  ad_domain_name = pillar['environments']['current']['ad_domain']['name']
  sssd_range_size = pillar['environments']['current']['sssd']['range_size']
  default_domain = pillar['environments']['current']['ad_domain']['fqdn']
  default_domain_sid = pillar['environments']['current']['ad_domain']['sid']
  env_current_name =  pillar['environments']['current']['name']

  ad_info = pillar['datacenters']['current']['ad_domain'][env_current_name]
  dc = pillar['datacenters']['current']['name'].downcase
  ad_server = ad_info['domain_controllers'][dc].join(",")
  ad_server_backup = ad_info['domain_controllers'][ad_info['ad_backup'][dc]].join(",")

  if grains['roles'].include? 'apache'
    ifp_allowed_uids = 'apache, root'
  else
    ifp_allowed_uids = 'root'
  end
  
  describe file('/etc/krb5.keytab') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0600' }
    its('owner') { should eq 'root' }
    its('group') { should eq  'root' }
  end
  
  describe file('/etc/sssd/sssd.conf') do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0600' }
    its('owner') { should eq 'root' }
    its('group') { should eq  'root' }
    its('content') { should match /# This file is managed by salt. Manual changes risk being overwritten./ }
    its('content') { should match(%r{\[sssd\]\nservices = nss, pam, pac, ifp\ndebug_level = 0x0270\ndomains = #{ad_domain_name}\nconfig_file_version = 2}) }
    its('content') { should match(%r{\[pam\]\npam_id_timeout = 60\ndebug_level = 5\noffline_failed_login_attempts = 3\noffline_failed_login_delay = 0\npam_verbosity = 1}) }
    its('content') { should match(%r{\[nss\]\nfilter_users = root, bin, daemon, adm, lp, sync, shutdown, halt, mail, uucp, operator, games, gopher, ftp, nobody, dbus, vcsa rpc, abrt, rpcuser, nfsnobody, haldaemon, ntp, saslauth, wasadm, postfix, sshd, tcpdump, oprofile, pcfmapp, nginx, jboss, apache, oracle, cloud-user\nvetoed_shells = /bin/ksh\nfilter_groups = root, bin, daemon, sys, adm, tty, disk, lp, mem, kmem, wheel, mail, uucp, man, games, gopher, video, dip, ftp, lock, audio, nobody,users,dbus,utmp,utempter, floppy, vcsa, rpc, abrt, cdrom, tape, dialout, wbpriv, rpcuser, nfsnobody, haldaemon, ntp, saslauth, postdrop, postfix, cgred, stapusr, stapsys, stapdev, sshd, tcpdump, oprofile, slocate, cfmapp, nginx, jboss, apache, wasadm, dba, oinstall, cloud-user\ndebug_level = 5\ndefault_shell = /bin/bash\nshell_fallback = /bin/bash\nfallback_homedir = /home/%u}) }
    its('content') { should match(%r{\[ifp\]\nuser_attributes = \+mail, \+givenname, \+sn, \+displayname\nallowed_uids = #{ifp_allowed_uids}}) }
    its('content') { should match(%r{\[domain/#{ad_domain_name}\]\nautofs_provider = none\nignore_group_members = True\nldap_idmap_default_domain = #{default_domain}\nselinux_provider = none\nauth_provider = ad}) }
    its('content') { should match(%r{override_gid = 100\ndebug_level = 5\nkrb5_auth_timeout = 60\nenumerate = False\ndyndns_update_ptr = False\nldap_id_mapping = True\nldap_idmap_default_domain_sid = #{default_domain_sid}}) }
    its('content') { should match(%r{ldap_idmap_range_size = #{sssd_range_size}\ndyndns_update = False\ndyndns_force_tcp = False\ndns_discovery_domain = #{default_domain}\ncache_credentials = True\nldap_user_extra_attrs = mail, givenname, sn, displayname}) }
    its('content') { should match(%r{ad_server = #{ad_server}\naccess_provider = ad\nldap_referrals = False\nchpass_provider = ad\nldap_idmap_range_max = 2000200000\nad_backup_server = #{ad_server_backup}\nldap_idmap_range_min = 200000\n}) }
    its('content') { should match(%r{ad_domain = #{default_domain}\nhostid_provider = none\nldap_purge_cache_timeout = 0\nid_provider = ad\nlookup_family_order = ipv4_only}) }
  end
  
  # Splunk forwarder checks (based on pillar data)
  describe file ('/opt/splunkforwarder/etc/apps/salt/local/inputs.conf') do
    its('content') { should match(%r{\[monitor:///var/log/sssd/krb5_child\.log\]\nindex = main\nsourcetype = sssd:krb5_child}) }
    # its('content') { should match(%r{\[monitor:///var/log/sssd/krb5_child\.log\]\nindex = main\nsourcetype = sssd:krb5_child\nkernel = Linux}) }
    its('content') { should match(%r{\[monitor:///var/log/sssd/ldap_child\.log\]\nindex = main\nsourcetype = sssd:ldap_child}) }
    its('content') { should match(%r{\[monitor:///var/log/sssd/sssd_ifp\.log\]\nindex = main\nsourcetype = sssd:ifp}) }
    its('content') { should match(%r{\[monitor:///var/log/sssd/sssd\.log\]\nindex = main\nsourcetype = sssd:sssd}) }
    its('content') { should match(%r{\[monitor:///var/log/sssd/sssd_nss\.log\]\nindex = main\nsourcetype = sssd:nss}) }
    its('content') { should match(%r{\[monitor:///var/log/sssd/sssd_pac\.log\]\nindex = main\nsourcetype = sssd:pac}) }
    its('content') { should match(%r{\[monitor:///var/log/sssd/sssd_pam\.log\]\nindex = main\nsourcetype = sssd:pam}) }
    its('content') { should match(%r{\[monitor:///var/log/sssd/sssd_#{ad_domain_name}\.log\]\nindex = main\nsourcetype = sssd:#{ad_domain_name}}) }
    # its('content') { should match(%r{\[monitor:///var/log/sssd/sssd\.log\]\nindex = main\nsourcetype = sssd:sssd\nkernel = Linux}) }
    # its('content') { should match(%r{\[monitor:///var/log/sssd/sssd_nss\.log\]\nindex = main\nsourcetype = sssd:nss\nkernel = Linux}) }
    # its('content') { should match(%r{\[monitor:///var/log/sssd/sssd_pac\.log\]\nindex = main\nsourcetype = sssd:pac\nkernel = Linux}) }
    # its('content') { should match(%r{\[monitor:///var/log/sssd/sssd_pam\.log\]\nindex = main\nsourcetype = sssd:pam\nkernel = Linux}) }
    # its('content') { should match(%r{\[monitor:///var/log/sssd/sssd_#{ad_domain_name}\.log\]\nindex = main\nsourcetype = sssd:#{ad_domain_name}\nkernel = Linux}) }
  end
  
  describe command("grep -Eq '^auth.*sufficient.*sss.so' /etc/pam.d/system-auth") do
    its('exit_status') { should eq 0 }
  end
  
  describe json('/etc/sensu/conf.d/checks.json') do
    its(['checks', 'base_linux_process_sssd', 'command']) { should eq "/opt/sensu/embedded/bin/check-process.rb -p /usr/sbin/sssd -C 1" }
    its(['checks', 'base_linux_process_sssd_be', 'command']) { should eq "/opt/sensu/embedded/bin/check-process.rb -p sssd_be -C 1" }
    its(['checks', 'base_linux_process_sssd_nss', 'command']) { should eq "/opt/sensu/embedded/bin/check-process.rb -p sssd_nss -C 1" }
    its(['checks', 'base_linux_process_sssd_pam', 'command']) { should eq "/opt/sensu/embedded/bin/check-process.rb -p sssd_pam -C 1" }
    its(['checks', 'base_linux_process_sssd_pac', 'command']) { should eq "/opt/sensu/embedded/bin/check-process.rb -p sssd_pac -C 1" }
    its(['checks', 'base_linux_process_sssd_ifp', 'command']) { should eq "/opt/sensu/embedded/bin/check-process.rb -p sssd_ifp -C 1" }
  end
end
