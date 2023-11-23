#!/bin/sh
BUILDROOT_DIR="/buildroot"
BOARD_DIR=$BUILDROOT_DIR/"$(dirname $0)"

cd $BUILDROOT_DIR/output/images

#install -m 0644 -D $BOARD_DIR/extlinux.conf $BINARIES_DIR/extlinux/extlinux.conf
mkimage -C none -A arm64 -T script -d $BOARD_DIR/boot.cmd boot.scr

#cp -v $BOARD_DIR/kernel_fdt.its .
#mkimage -f kernel_fdt.its -E Image.itb

dd if=/dev/zero of=boot.ext4 bs=1024 count=65536 # ext4 file of 64M
mkfs.ext4 -L boot boot.ext4
mount -o loop boot.ext4 /mnt

cp -v Image sun50i-h5-nanopi-neo-plus2.dtb uInitrd boot.scr /mnt/
umount /mnt
