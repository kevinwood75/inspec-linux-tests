control "git-1.0" do
  impact 1.0
  title 'git'
  desc "Validate git installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat'
  end

  describe package('git') do
    it { should be_installed }
  end

  if grains['roles'].include? 'gitlab'
    describe port(8080) do
      it { should be_listening }
    end

    describe port(80) do
      it { should be_listening }
    end

    describe port(56681) do
      it { should be_listening }
    end

    describe port(5432) do
      it { should be_listening }
    end
  end
end
