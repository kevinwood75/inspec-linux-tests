control "websphere_nd-1.0" do
  impact 1.0
  title 'websphere_nd'
  desc "Validate websphere_nd installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['roles'].include? 'websphere_nd'
  end

  begin
    websphere_nd_ver = grains['IBM']['WebSphere']['ND']['version']
  rescue NoMethodError
    websphere_nd_ver = ''
  end

  if websphere_nd_ver.to_s.include? '8.5.5'
    if grains['IBM']['WebSphere']['Node']['dmgr']
      describe 'WebSphere 8.5.5 DMGR firewall tests' do
        describe port(19001) do
          it { should be_listening }
        end

        describe port(19003) do
          it { should be_listening }
        end
      end
    end

    if grains['IBM']['WebSphere']['Node']['managed']
      describe 'WebSphere 8.5.5 MANAGED node firewall tests' do
      end
    end

    if grains['IBM']['WebSphere']['Node']['unmanaged']
      describe 'WebSphere 8.5.5 UNMANAGED node port and firewall tests' do

        # SSL Ports are only opened when a SSL connection is initiated
        describe port(8008) do
          it { should be_listening }
        end
      end
    end
  end

  if websphere_nd_ver.to_s.include? '8.0'
    if grains['IBM']['WebSphere']['Node']['dmgr']
      describe 'WebSphere 8.0.0 DMGR firewall tests' do
        describe port(18001) do
          it { should be_listening }
        end

        describe port(18003) do
          it { should be_listening }
        end
      end
    end

    if grains['IBM']['WebSphere']['Node']['managed']
      describe 'WebSphere 8.0.0 MANAGED node firewall tests' do
      end
    end

    if grains['IBM']['WebSphere']['Node']['unmanaged']
      describe 'WebSphere 8.0 UNMANAGED node port and firewall tests' do

        # SSL Ports are only opened when a SSL connection is initiated
        describe port(8008) do
          it { should be_listening }
        end
      end
    end
  end
end