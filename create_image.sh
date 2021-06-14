#!/bin/bash

set -e

echo -e "[Create disk image]"
dd if=/dev/zero of=/os/linux.img bs=$(expr 1024 \* 1024 \* 1024) count=1

echo -e "\n[Make partition]"
sfdisk /os/linux.img < /os/partition.txt

echo -e "\n[Format partition with ext4]"
losetup -D
LOOPDEVICE="$(losetup -f)"
echo -e "[Using ${LOOPDEVICE} loop device]"
losetup -o "$(expr 512 \* 2048)" "${LOOPDEVICE}" /os/linux.img
mkfs.ext4 "${LOOPDEVICE}"

echo -e "\n[Copy linux directory structure to partition]"
mkdir -p /os/mnt
mount -t auto,rw "${LOOPDEVICE}" /os/mnt/
cp -R /os/linux.dir/. /os/mnt/

echo -e "\n[Setup extlinux]"
extlinux --install /os/mnt/boot/
cp /os/"${DISTR}"/syslinux.cfg /os/mnt/boot/syslinux.cfg

echo -e "\n[Make filesystem writeable]"
FS_ROW="$(blkid | awk -F\" "/$(basename "${LOOPDEVICE}")/ {print \"UUID=\"\$2\" / ext4 defaults 0 0\"}")"
echo -e "${FS_ROW}" > /os/mnt/etc/fstab

echo -e "\n[fdisk -l]" && fdisk -l
echo -e "\n[blkid]" && blkid
echo -e "\n[cat /os/mnt/etc/fstab]" && cat /os/mnt/etc/fstab

echo -e "\n[Unmount]"
umount /os/mnt
losetup -D

echo -e "\n[Write syslinux MBR]"
dd if=/usr/lib/syslinux/mbr/mbr.bin of=/os/linux.img bs=440 count=1 conv=notrunc
