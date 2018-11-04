control "cloudify_manager-1.0" do
  impact 1.0
  title 'cloudify_manager'
  desc "Validate cloudify manager installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['roles'].include?('cloudifymanager')
  end

  describe service('cloudify') do
    it { should be_installed }
  end
=begin
 describe file('/root/cloudify/manager/files/cloudifymanager_celeryd_starter.py') do
   it { should exist }
   its('mode') { should cmp '0770' }
 end

 describe file('/opt/splunkforwarder/etc/apps/salt/local/inputs.conf') do
   its('content') { should match(%r{\[monitor:///var/tmp/rabbitmq-tracing/all\.log\]\nindex = main\nsourcetype = storm:cloudify:rabbitmq}) }
   its('content') { should match(%r{\[monitor:///home/cloudify/cloudify\.\*_workflows/work/celery\.log\]\nindex = main\nsourcetype = cloudify:manager:celery:workflow}) }
   its('content') { should match(%r{\[monitor:///home/cloudify/cloudify\.\*/work/celery\.log\]\nindex = main\nsourcetype = cloudify:manager:celery:agent\nblacklist = (\*_workflows)}) }
   its('content') { should match(%r{\[monitor:///opt/celery/cloudify\.management__worker/work/cloudify\.management_worker\.log\]\nindex = main\nsourcetype = cloudify:manager:celery:management_worker}) }
 end
 
 describe command("curl -i -u guest:guest -H \"content-type:application/json\" -XPUT  http://localhost:15672/api/traces/%2f/all -d'{\"format\":\"json\",\"pattern\":\"#\"}' ") do
   its('exit_status') { should eq 0 }
 end
 
  describe crontab('root') do
    its('commands') { should include "/root/cloudify-celeryd-starter/cloudifymanager_celeryd_starter.py" }
  end
=end
end
