control "lvm_storage-1.0" do
  impact 1.0
  title 'lvm_storage'
  desc "Validate lvm_storage installation"

  params = salt_info
  grains = params.grains

  only_if do
    grains['os_family'] == 'RedHat' and grains['lvms']
  end

  grains['lvms'].each_with_index do |lvm, index|
    lvm_item = grains[lvm]

    describe mount(lvm_item['mountpoint']) do
      it { should be_mounted }
      its('device') { should eq "/dev/mapper/#{lvm_item['vg']}-#{lvm}" }
      its('type') { should eq lvm_item['fstype'] }
      its('options') { should eq ["rw", "noatime", "nodiratime", "seclabel", "attr2", "nobarrier", "inode64", "logbufs=8", "noquota"] }
    end

    describe file(lvm_item['mountpoint']) do
      # assert device from volume group and lv name
      # it { should be_mounted.with( :device => "/dev/mapper/#{lvm_item['vg']}-#{lvm}" ) }
      # assert filesystem type
      # it { should be_mounted.with( :type => lvm_item['fstype'] ) }
      # assert the owner of the lv
      its('owner') { should eq lvm_item['os_user'] }
      # assert the group of the lv
      its('group') { should eq lvm_item['os_group'] }
      # assert the permission mode of the lv
      perm = "0#{lvm_item['mp_permissions']}"
      its('mode') { should cmp perm }
    end
  end
end