control "ucmdb-1.0" do
  impact 1.0
  title 'ucmdb'
  desc "Validate ucmdb installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat'
  end

  describe user('pcfmapp') do
    it { should exist }
    its('group') { should eq 'cfmapp' }
    its('groups') { should eq [ 'cfmapp','cmdblin' ]}
    its('home') { should eq '/home/pcfmapp' }
  end

  describe group('cmdblin') do
    it { should exist }
    its('gid') { should eq 3124 }
  end

  describe file('/home/pcfmapp/.ssh/authorized_keys') do
    it { should exist }
    it { should be_file }
    its('owner') { should eq 'pcfmapp' }
    its('group') { should eq 'cfmapp' }
    its('mode') { should cmp '0600' }
    its('content') { should match /AAAAB3NzaC1yc2EAAAABJQAAAQEAillW1KR00m9dpCNXFOe4Nmlze8SaPH7yaYVVbi1kn6glPIjNmiHXI6gD9bN9Wb7JQeF2r6cyAO1bkj3qHlVJxRAsu3HBjsZXowExN\+LJaoDoaZKm\/rfTz7hW\+DfXOYNMbkXlGyqlPLKonTgWp6ISUzga81fPZREvBrTCEWV2z46\+YFs4mqkDwHYsRYl4mq\/QxymVcJ3tZN6KViLPxxpEzwQGfCDKGjgknkLzryzcKF\+yCfYbTIbjeNU5ZoMmLFhAJknu1V7RpV5JgfKpszSnFSlp8n1eFhQ9Svp69pnJwWcW6I5SU\+Fka\+mDsu3EPbnd9RBKQe6aNUWL7DKYJkt8DQ== pcfmapp/ }
  end

  describe group('cfmapp') do
    it { should exist }
  end
end
