control "certs-1.0" do
  impact 1.0
  title 'certs'
  desc "Validate certs installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat'
  end

  describe package('ca-certificates') do
    it { should be_installed }
  end

  describe file('/etc/pki/ca-trust/source/anchors/D2-BKNGIssuingCA02.cer') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('mode') { should cmp '0644' }
    its('md5sum') { should eq '428cfedfe21c66f70afd001a83281c2c' }
  end

  describe file('/etc/pki/ca-trust/source/anchors/S-TDBFGIssuingCA02.cer') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('mode') { should cmp '0644' }
    its('md5sum') { should eq 'f310bed5c8ae520c25ec987da1d5ab90' }
  end

  describe file('/etc/pki/ca-trust/source/anchors/S-TDBFGPolicyCA02.cer') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('mode') { should cmp '0644' }
    its('md5sum') { should eq '39c1c74489fe7f24e7da9a2d034991a4' }
  end

  describe file('/etc/pki/ca-trust/source/anchors/S-TDBFGRootCA.cer') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('mode') { should cmp '0644' }
    its('md5sum') { should eq '32dfee549990dc2362bc047ce0d2fcc5' }
  end

  describe file('/etc/pki/ca-trust/source/anchors/TDBFGIssuingCA02.cer') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('mode') { should cmp '0644' }
    its('md5sum') { should eq 'a57387ee6d8057836cafde5504aeab05' }
  end

  describe file('/etc/pki/ca-trust/source/anchors/TDBFGPolicyCA02.cer') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('mode') { should cmp '0644' }
    its('md5sum') { should eq 'a7af26f70abc7bc8ba53ca0b305f9d5c' }
  end

  describe file('/etc/pki/ca-trust/source/anchors/TDBFGRootCA.cer') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('mode') { should cmp '0644' }
    its('md5sum') { should eq '2bf90084e1f27ccba48daccfa5d865ad' }
  end

  describe file('/etc/pki/ca-trust/source/anchors/TDCAroot.cer') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('mode') { should cmp '0644' }
    its('md5sum') { should eq '3f4797d7280852c7167f31e5fab4be95' }
  end

  describe file('/etc/pki/ca-trust/source/anchors/td-internet-browsing-ca.cer') do
    it { should exist }
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its('mode') { should cmp '0644' }
    its('md5sum') { should eq '08538081f48c4c4f7dd6e687869c57f3' }
  end

  describe command("grep -v ^# /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem |awk -v cmd='openssl x509 -noout -subject' '/BEGIN/{close(cmd)};{print | cmd}'|grep -q 'CN=S-TDBFGRootCA'") do
    its('exit_status') { should eq 0 }
  end

  describe command("grep -v ^# /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem |awk -v cmd='openssl x509 -noout -subject' '/BEGIN/{close(cmd)};{print | cmd}'|grep -q 'CN=D2-BKNGIssuingCA02'") do
    its('exit_status') { should eq 0 }
  end

  describe command("grep -v ^# /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem |awk -v cmd='openssl x509 -noout -subject' '/BEGIN/{close(cmd)};{print | cmd}'|grep -q 'CN=S-TDBFGIssuingCA02'") do
    its('exit_status') { should eq 0 }
  end

  describe command("grep -v ^# /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem |awk -v cmd='openssl x509 -noout -subject' '/BEGIN/{close(cmd)};{print | cmd}'|grep -q 'CN=TD Bank Group SHA2 Internal Browsing Root Certificate'") do
    its('exit_status') { should eq 0 }
  end

  describe command("grep -v ^# /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem |awk -v cmd='openssl x509 -noout -subject' '/BEGIN/{close(cmd)};{print | cmd}'|grep -q 'CN=TDBFGIssuingCA02'") do
    its('exit_status') { should eq 0 }
  end

  describe command("grep -v ^# /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem |awk -v cmd='openssl x509 -noout -subject' '/BEGIN/{close(cmd)};{print | cmd}'|grep -q 'CN=S-TDBFGPolicyCA02'") do
    its('exit_status') { should eq 0 }
  end

  describe command("grep -v ^# /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem |awk -v cmd='openssl x509 -noout -subject' '/BEGIN/{close(cmd)};{print | cmd}'|grep -q 'CN=TDRootCA_Prod'") do
    its('exit_status') { should eq 0 }
  end
end