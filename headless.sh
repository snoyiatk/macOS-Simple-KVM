#!/bin/bash

OSK="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
VMDIR=$PWD
OVMF=$VMDIR/firmware

[[ -z "$MEM" ]] && {
	MEM="16G"
}

[[ -z "$CPUS" ]] && {
	CPUS=4
}

[[ -z "$SYSTEM_DISK" ]] && {
    SYSTEM_DISK=MacOS_Disk.qcow2
    # echo "Please set the SYSTEM_DISK environment variable"
    # exit 1
}

[[ -r "$SYSTEM_DISK" ]] || {
    echo "Can't read system disk image: $SYSTEM_DISK"
    exit 1
}

MOREARGS=(-netdev user,id=net0,hostfwd=tcp::30022-:22 -nic user,model=virtio-net-pci )

[[ "$HEADLESS" = "1" ]] && {
    MOREARGS+=( -nographic -vnc :0 -k en-us)
}

qemu-system-x86_64 \
    -enable-kvm \
    -m $MEM \
    -machine q35,accel=kvm \
    -smp $CPUS \
    -cpu Penryn,vendor=GenuineIntel,kvm=on,+ssse3,+sse4.2,+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe,+invtsc \
    -device isa-applesmc,osk="$OSK" \
    -smbios type=2 \
    -drive if=pflash,format=raw,readonly,file="$OVMF/OVMF_CODE.fd" \
    -drive if=pflash,format=raw,file="$OVMF/OVMF_VARS-1024x768.fd" \
    -vga qxl \
    -usb -device usb-kbd -device usb-tablet \
    -netdev user,id=net0 \
    -device e1000-82545em,netdev=net0,id=net0,mac=fa:ab:b4:94:43:a6 \
    -device ich9-ahci,id=sata \
    -drive id=ESP,if=none,format=qcow2,file=ESP.qcow2 \
    -device ide-hd,bus=sata.2,drive=ESP \
    -drive id=InstallMedia,format=raw,if=none,file=BaseSystem.img \
    -device ide-hd,bus=sata.3,drive=InstallMedia \
    -drive id=SystemDisk,if=none,file="${SYSTEM_DISK}" \
    -device ide-hd,bus=sata.4,drive=SystemDisk \
    "${MOREARGS[@]}"
    # -set device.sata0-0-1.rotation_rate=1
    # -nic user,model=virtio-net-pci
    # -netdev user,id=net0,model=virtio,hostfwd=tcp::30022-:22 \
    # -netdev tap,id=net0,ifname=tap0,script=no,downscript=no
    # OR
    # -netdev user,id=net0,model=virtio-net-pci,hostfwd=tcp::30022-:22
