control "ntp-1.0" do
  impact 1.0
  title 'ntp'
  desc "Validate ntp installation"

  params = salt_info
  grains = params.grains
  pillar = params.pillar
  
  only_if do
    grains['os_family'] == 'RedHat'
  end

  if grains['osrelease'].start_with?('6')
  
    ntp_conf = pillar['ntp']['ntp_conf']
    ntpfile = '/etc/ntp.conf'

    describe package('ntpdate') do
      it { should be_installed }
    end

    describe service('ntpdate') do
      it { should be_enabled }
      it { should be_running }
    end

    describe package('ntp') do
      it { should be_installed }
    end

    describe service('ntpd') do
      it { should be_enabled }
      it { should be_running }
    end

    describe file('/etc/sysconfig/ntpdate') do
      it { should exist }
      it { should be_file }
      its('mode') { should cmp '0644' }
      its('owner') { should eq 'root' }
      its('group') { should eq 'root' }
    end

    describe file('/etc/ntp/step-tickers') do
      it { should exist }
      it { should be_file }
      its('mode') { should cmp '0644' }
      its('owner') { should eq 'root' }
      its('group') { should eq 'root' }
    end

  elsif grains['osrelease'].start_with?('7')

    ntp_conf = pillar['ntp']['chrony_conf']
    ntpfile = '/etc/chrony.conf'

    describe package('chrony') do
      it { should be_installed }
    end

    describe service('chronyd') do
      it { should be_enabled }
      it { should be_running }
    end
  end

  describe file(ntpfile) do
    it { should exist }
    it { should be_file }
    its('mode') { should cmp '0644' }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    ntp_conf.each do |declaration, values|
      if (values.kind_of?(Array)) then
        values.each do |value|
          its('content') { should match /#{declaration}\s*#{value}/ }
        end
      else
        its('content') { should match /#{declaration}\s*#{values}/ }
      end
    end
  end
end
