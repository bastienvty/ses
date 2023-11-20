#!/bin/sh
BOARD_DIR="$(dirname $0)"
BUILDROOT_DIR="/buildroot"
IMAGES_DIR=$BUILDROOT_DIR/"output/images"

#install -m 0644 -D $BOARD_DIR/extlinux.conf $BINARIES_DIR/extlinux/extlinux.conf
mkimage -C none -A arm64 -T script -d $BOARD_DIR/boot.cmd $BUILDROOT_DIR/output/images/boot.scr

cp -v $BOARD_DIR/kernel_fdt.its $BUILDROOT_DIR/output/images/.
mkimage -f $BUILDROOT_DIR/output/images/kernel_fdt.its -E $BUILDROOT_DIR/output/images/Image.itb

dd if=/dev/zero of=boot.ext4 bs=1024 count=65536 # ext4 file of 64M
mkfs.ext4 -L boot boot.ext4
mount -o loop boot.ext4 /mnt

cp -r $BUILDROOT_DIR/output/images/Image.itb $BUILDROOT_DIR/output/images/boot.scr /mnt/.
umount /mnt
mv boot.ext4 $BUILDROOT_DIR/output/images/.

dd if=/dev/zero of=dev.btrfs bs=1M count=400 # btrfs file of 400M
apt install btrfs-progs -y
mkfs.btrfs dev.btrfs
btrfs filesystem label dev.btrfs dev_btrfs
mv dev.btrfs $BUILDROOT_DIR/output/images/.

dd if=/dev/zero of=dev.f2fs bs=1M count=400
apt install f2fs-tools -y
mkfs.f2fs -l dev_f2fs dev.f2fs
mv dev.f2fs $BUILDROOT_DIR/output/images/.