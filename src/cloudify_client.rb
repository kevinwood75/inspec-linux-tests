control "cloudify_client-1.0" do
  impact 1.0
  title 'cloudify_client'
  desc "Validate cloudify client installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['roles'].include?('linux_cloudify_client') or grains['roles'].include?('cloudifyclient')
  end

  describe file('/home/cloud-user/cloudify-celeryd-starter/cloudifyclient_celeryd_starter.py') do
    it { should exist }
    it { should be_owned_by 'cloud-user' }
    it { should be_grouped_into 'cloud-user' }
    its('mode') { should cmp '0770' }
    its('md5sum') { should eq '8b52acc322b7d729663fcd73d3c947fe' }
  end

  describe file ('/opt/splunkforwarder/etc/apps/salt/local/inputs.conf') do
    its('content') { should match(%r{\[monitor:///home/cloud-user/\*/work/celery\.log\]\nindex = main\nrecursive = true\nsourcetype = cloudify:client:celery:agent}) }
  end
  
  describe crontab('root') do
    its('commands') { should include "su - cloud-user -c '/home/cloud-user/cloudify-celeryd-starter/cloudifyclient_celeryd_starter.py'"}
  end
end
