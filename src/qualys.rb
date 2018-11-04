control "qualys-1.0" do
  impact 1.0
  title 'qualys'
  desc "Validate qualys installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat'
  end

  describe file('/etc/passwd') do
    its('content') { should match /qualys:x:.*:.*:Qualys Audit Account/ }
  end

  describe group('qualys') do
    it { should exist }
  end

  describe user('qualys') do
    it { should exist }
    its('group') { should eq 'qualys' }
  end

  describe file('/home/qualys/.ssh/authorized_keys') do
    it { should exist }
    it { should be_file }
    its('content') { should match /ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAwTd0Wpt9y2MDfyMpI1q7\/ZWAc7nUzZQUxp3huSIKmth67AD72\+6\/pVFcgGMZZmzzBUYkePcVx4bFiUss7g1\/z3kZMAtibGF2UdZuONkyfMnecLC8g5JZngQQw1tf7tBMj8GWc0IrtvIKwOSH22WpNTKaJ6LtS8O0xfF\+CODobXcS1ThuMIZ9OGhyi0YPjphlS9TqNOX\/IF95AzwINHmw\/c4YnSS7gSbZ\/FuEIE9\/xZA0uZA\+e\+ULRInoMd9ZaTqmBaYaT\/EwTCLB9cjQt3t\/EzGMBk8KMxk0siJYPRgk4EgCxoqdOjzfxLvgtnvhz9TRKIwpBz6U8ubcOO9z10fjiw==/ }
  end
end
