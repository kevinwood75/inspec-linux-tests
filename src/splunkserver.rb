control "splunkserver-1.0" do
  impact 1.0
  title 'splunkserver'
  desc "Validate splunkserver installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['roles'].include? 'splunkserver'
  end

  [8089, 9997, 9998, 8443, 1514].each do |p|
    describe port(8089) do
      it { should be_listening }
    end
  end
end
