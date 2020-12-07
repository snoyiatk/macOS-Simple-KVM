#!/bin/bash
# https://github.com/SnoyIatK/macOS-Simple-KVM.git

RUN_USER=$USER
# RUN_USER=vmadmin

####################################################################
sudo apt update
sudo apt install -y uml-utilities net-tools git wget jq
egrep -c '(vmx|svm)' /proc/cpuinfo
sudo apt install -y qemu qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager virtinst libguestfs-tools libosinfo-bin cpu-checker
sudo kvm-ok
sudo service libvirtd start
sudo systemctl enable --now libvirtd
# echo 1 > /sys/module/kvm/parameters/ignore_msrs
export LIBVIRT_DEFAULT_URI=qemu:///system
sudo usermod -aG kvm,tty $USER
# echo "export LIBVIRT_DEFAULT_URI=\"qemu:///system\"" >> $HOME/.bashrc


####################################################################
# Login using managed identity
wget -O azcopy_v10.tar.gz https://aka.ms/downloadazcopy-v10-linux && tar -xf azcopy_v10.tar.gz --strip-components=1
sudo cp azcopy /usr/local/bin/
/usr/local/bin/azcopy login --identity


# ####################################################################
virsh net-start default
virsh net-autostart default

sudo ip tuntap add dev tap0 mode tap
sudo ip link set tap0 up promisc on
sudo ip link set dev virbr0 up
sudo ip link set dev tap0 master virbr0

sudo mkdir /mnt/dev
sudo chown -R $RUN_USER:$RUN_USER /mnt/dev


# ####################################################################
# git clone --depth 1 https://github.com/kholia/OSX-KVM.git /mnt/dev/OSX-KVM
# cd /mnt/dev/OSX-KVM
# sudo cp kvm.conf /etc/modprobe.d/kvm.conf
# sudo apt install python -y
# qemu-img convert BaseSystem.dmg -O raw BaseSystem.img
# qemu-img create -f qcow2 mac_hdd_ng.img 128G
# ./OpenCore-Boot.sh


# ####################################################################
# git clone https://github.com/foxlet/macOS-Simple-KVM.git /mnt/dev/macOS-Simple-KVM
# cd /mnt/dev/macOS-Simple-KVM
# ./jumpstart.sh --catalina
# qemu-img create -f qcow2 MacOS_Disk.qcow2 128G
# echo >> basic.sh
# echo "    -drive id=SystemDisk,if=none,file=MacOS_Disk.qcow2 \\" >> basic.sh
# echo "    -device ide-hd,bus=sata.4,drive=SystemDisk \\" >> basic.sh
# echo "    -nographic -vnc :0 -k en-us" >> basic.sh


####################################################################
SRC=$HOME/macOS-Simple-KVM
git clone https://github.com/SnoyIatK/macOS-Simple-KVM.git $SRC
git -C $SRC pull
ln -s $SRC/devcontainer-init.sh $HOME/devcontainer-init.sh

# /mnt is temporary disk
mkdir /mnt/dev/macOS-Simple-KVM
cp -r $SRC/firmware /mnt/dev/macOS-Simple-KVM/
# Download (azcopy sync sometimes fails with 401?)
/usr/local/bin/azcopy copy "https://cuongdevcontainersa.blob.core.windows.net/macos/full/disk/*" "/mnt/dev/macOS-Simple-KVM/" --recursive
# Upload
# /usr/local/bin/azcopy copy "/mnt/dev/macOS-Simple-KVM/*" "https://cuongdevcontainersa.blob.core.windows.net/macos/full/disk/" --exclude-path=".git;.github;.gitignore;.gitmodules" --recursive

# /usr/local/bin/azcopy sync "/mnt/dev/macOS-Simple-KVM" "https://cuongdevcontainersa.blob.core.windows.net/macos/full/disk/" --exclude-path=".git;.github;.gitignore;.gitmodules" --recursive --delete-destination true

# sudo ip link delete tap0
virsh define $SRC/macOS-KVM.xml
virsh start macOS-KVM
# sudo virsh start macOS-KVM #sudo required for tun/tap
