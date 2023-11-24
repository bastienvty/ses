#!/bin/bash 
RAMFS=/buildroot/ramfs
RAMFS2=$RAMFS/t
mkdir $RAMFS
mkdir $RAMFS2
cd $RAMFS

mkdir -p $RAMFS2/{bin,dev,etc,home,lib,newroot,proc,root,usr/bin,usr/sbin,usr/lib,sbin,sys,run}

cd $RAMFS2
cd root
cp $1 . # copy passphrase into the initramfs /root

cd $RAMFS2
cd bin
cp /buildroot/output/target/bin/busybox .

ln -s busybox mount
ln -s busybox umount
ln -s busybox sh
ln -s busybox dmesg
ln -s busybox echo
ln -s busybox ls
ln -s busybox ln
ln -s busybox mkdir
ln -s busybox mknod
ln -s busybox sleep
ln -s busybox df

cd $RAMFS2
cd usr/bin
cp /buildroot/output/target/usr/bin/strace . 

cd $RAMFS2
cd sbin
ln -s ../bin/busybox switch_root 

cd $RAMFS2
cd lib
cp /buildroot/output/target/lib/ld-uClibc-1.0.42.so .
cp /buildroot/output/target/lib/libuClibc-1.0.42.so .
ln -s ld-uClibc-1.0.42.so ld-uClibc.so.1
ln -s ld-uClibc.so.1 ld-uClibc.so.0
ln -s libuClibc-1.0.42.so libc.so.0
ln -s libuClibc-1.0.42.so libc.so.1
cd $RAMFS2

### LUKFS
cd $RAMFS2
cd usr/sbin
cp /buildroot/output/target/usr/sbin/cryptsetup .

cd $RAMFS2
cd usr/lib
cp /buildroot/output/target/usr/lib/libcryptsetup.so.12.8.0 .
ln -s libcryptsetup.so.12.8.0 libcryptsetup.so.12
ln -s libcryptsetup.so.12.8.0 libcryptsetup.so

cp /buildroot/output/target/usr/lib/libpopt.so.0.0.1 .
ln -s libpopt.so.0.0.1 libpopt.so.0
ln -s libpopt.so.0.0.1 libpopt.so

cp /buildroot/output/target/usr/lib/libdevmapper.so.1.02 .
ln -s libdevmapper.so.1.02 libdevmapper.so

cp /buildroot/output/target/usr/lib/libssl.so.1.1 .
ln -s libssl.so.1.1 libssl.so

cp /buildroot/output/target/usr/lib/libcrypto.so.1.1 .
ln -s libcrypto.so.1.1 libcrypto.so

cp /buildroot/output/target/usr/lib/libargon2.so.1 .
ln -s libargon2.so.1 libargon2.so

cp /buildroot/output/target/usr/lib/libjson-c.so.5.2.0 .
ln -s libjson-c.so.5.2.0 libjson-c.so.5
ln -s libjson-c.so.5 libjson-c.so

cp /buildroot/output/target/usr/lib/libiconv.so.2.6.0 .
ln -s libiconv.so.2.6.0 libiconv.so.2
ln -s libiconv.so.2.6.0 libiconv.so

ln -s ../../lib/libuuid.so.1.3.0 libuuid.so
ln -s ../../lib/libblkid.so.1.1.0 libblkid.so

cd $RAMFS2
cd lib
cp /buildroot/output/target/lib/libuuid.so.1.3.0 .
ln -s libuuid.so.1.3.0 libuuid.so.1

cp /buildroot/output/target/lib/libblkid.so.1.1.0 .
ln -s libblkid.so.1.1.0 libblkid.so.1

cp /buildroot/output/target/lib/libatomic.so.1.2.0 .
ln -s libatomic.so.1.2.0 libatomic.so.1
ln -s libatomic.so.1.2.0 libatomic.so

cd $RAMFS2
######initialize the /init file 
cat > init << endofinput 
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -n -t devtmpfs devtmpfs /dev

cryptsetup --debug open --type luks --key-file /root/passphrase /dev/mmcblk0p3 usrfs1
mount /dev/mapper/usrfs1 /newroot
mount -n -t devtmpfs devtmpfs /newroot/dev

#exec sh
exec switch_root /newroot /sbin/init 
endofinput
######
chmod 755 init

cd $RAMFS2
find . | cpio --quiet -o -H newc > ../Initrd

cd $RAMFS
gzip -9 -c Initrd > Initrd.gz
mkimage -A arm -T ramdisk -C none -d Initrd.gz uInitrd

cp /buildroot/ramfs/uInitrd /buildroot/output/images/.
cd /buildroot
rm -rf $RAMFS