control "autosys-1.0" do
  impact 1.0
  title 'autosys'
  desc "Validate autosys installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include?('scheduler_client')
  end

  describe grains['scheduler_type'] do
    it { should_not be_nil }
    it { is_expected.to eq('autosys').or(eq('ca7')) }
  end

  describe grains['scheduler_virtual_agent'] do
    it { should_not be_nil }
  end

  describe grains['scheduler_environment'] do
    it { should_not be_nil }
  end

  describe service('cybagent') do
    it { should be_enabled }
  end

  describe service('cybagent') do
    it { should be_running }
  end

  describe port(7520) do
    it { should be_listening }
  end
end
