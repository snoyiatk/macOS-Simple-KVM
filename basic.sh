#!/bin/bash

OSK="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
VMDIR=$PWD
OVMF=$VMDIR/firmware
#export QEMU_AUDIO_DRV=pa
#QEMU_AUDIO_DRV=pa

# QEMU supported MAC
# printf '52:54:00:AB:%02X:%02X\n' $((RANDOM%256)) $((RANDOM%256))  # generates QEMU compatible mac addresses!

qemu-system-x86_64 \
    -enable-kvm \
    -m 16G \
    -machine q35,accel=kvm \
    -smp 4,cores=2 \
    -cpu Penryn,vendor=GenuineIntel,kvm=on,+ssse3,+sse4.2,+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe,+invtsc \
    -device isa-applesmc,osk="$OSK" \
    -smbios type=2 \
    -drive if=pflash,format=raw,readonly,file="$OVMF/OVMF_CODE.fd" \
    -drive if=pflash,format=raw,file="$OVMF/OVMF_VARS-1024x768.fd" \
    -vga qxl \
    -device ich9-intel-hda -device hda-output \
    -usb -device usb-kbd -device usb-tablet \
    -netdev tap,id=net0,ifname=tap0,script=no,downscript=no \
    -device e1000-82545em,netdev=net0,id=net0,mac=52:54:00:AB:9F:FC \
    -device ich9-ahci,id=sata \
    -drive id=ESP,if=none,format=qcow2,file=ESP.qcow2 \
    -device ide-hd,bus=sata.2,drive=ESP \
    -drive id=InstallMedia,format=raw,if=none,file=BaseSystem.img \
    -device ide-hd,bus=sata.3,drive=InstallMedia \
    -drive id=SystemDisk,if=none,file=MacOS_Disk.qcow2,discard=unmap,rotation_rate=1 \
    -device ide-hd,bus=sata.4,drive=SystemDisk,rotation_rate=1 \
    -nographic -vnc :0 -k en-us
    # -set device.sata0-0-4.rotation_rate=1
    # -nic user,model=virtio-net-pci
    # -netdev user,id=net0,model=virtio,hostfwd=tcp::30022-:22 \
    # -netdev tap,id=net0,ifname=tap0,script=no,downscript=no
    # OR
    # -netdev user,id=net0,model=virtio-net-pci,hostfwd=tcp::30022-:22
