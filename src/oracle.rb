control "oracle-1.0" do
  impact 1.0
  title 'oracle'
  desc "Validate oracle installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'oracle'
  end

  # Oracle only listens port#1515: /blueprints/3.1/blueprints/oracle/scripts/oracle/create.py, /blueprints/3.1/blueprints/oracle11g/scripts/oracle/create.py
  describe port(1515) do
    it { should be_listening }
  end
  # Port #8403 is a Commvault listener for backups too
  describe port(8403) do
    it { should be_listening }
  end
end