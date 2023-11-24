#!/bin/sh
BUILDROOT_DIR="/buildroot"
BOARD_DIR=$BUILDROOT_DIR/"$(dirname $0)"
IMAGES_DIR=$BUILDROOT_DIR/output/images
DEVICE=rootfs.lukfs

cd $BOARD_DIR

apt install cryptsetup -y
dd if=/dev/urandom of=passphrase bs=64 count=1
dd if=/dev/zero of=rootfs.lukfs bs=2147483648 count=1

cryptsetup --debug --pbkdf pbkdf2 --key-file passphrase --batch-mode luksFormat $DEVICE
cryptsetup --debug open --type luks --key-file passphrase $DEVICE usrfs1

mkfs.ext4 /dev/mapper/usrfs1
mkdir /mnt/lukfs
mkdir /mnt/rootfs

mount /dev/mapper/usrfs1 /mnt/lukfs
mount $IMAGES_DIR/rootfs.ext4 /mnt/rootfs
cp -pr /mnt/rootfs/* /mnt/lukfs/

umount $IMAGES_DIR/rootfs.ext4
umount /dev/mapper/usrfs1
cryptsetup close usrfs1
rm -r /mnt/lukfs
rm -r /mnt/rootfs

mv rootfs.lukfs $IMAGES_DIR/.

./initramfs.sh $BOARD_DIR/passphrase
rm passphrase

cd $IMAGES_DIR

#install -m 0644 -D $BOARD_DIR/extlinux.conf $BINARIES_DIR/extlinux/extlinux.conf
mkimage -C none -A arm64 -T script -d $BOARD_DIR/boot.cmd boot.scr

#cp -v $BOARD_DIR/kernel_fdt.its .
#mkimage -f kernel_fdt.its -E Image.itb

dd if=/dev/zero of=boot.ext4 bs=1024 count=65536 # ext4 file of 64M
mkfs.ext4 -L boot boot.ext4
mount -o loop boot.ext4 /mnt

cp -v Image sun50i-h5-nanopi-neo-plus2.dtb uInitrd boot.scr /mnt/
umount /mnt
