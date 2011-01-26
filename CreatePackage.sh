#!/bin/bash

#TODO add interface for usb0
#TODO add embedded erlang logo

#Small scripts to prepear a release tar, run with root priviledges

RELEASE="harbor-seal"

TAR=tar #Use gnutar for mac
TAR_EXTRACT_BZIP="xjf"
TAR_EXTRACT_GZ="xzf"
TAR_COMPRESS_BZIP="cfj"

LIBC=$1

mkdir -p /tmp/EmbErl/opt/local/erlang

${TAR} ${TAR_EXTRACT_BZIP} ${LIBC}/deploy/${LIBC}/images/beagleboard/minimalist-image-beagleboard.tar.bz2 -C /tmp/EmbErl/

${TAR} ${TAR_EXTRACT_GZ} erlang-${RELEASE}.tgz -C /tmp/EmbErl/opt/local/erlang/

pushd /tmp/EmbErl
${TAR} ${TAR_COMPRESS_BZIP} rootfs.tar.bz2 *
popd

mv /tmp/EmbErl/rootfs.tar.bz2 .

rm -rf /tmp/EmbErl/*

#cp ${LIBC}/deploy/${LIBC}/images/beagleboard/MLO-beagleboard /tmp/EmbErl/MLO
#cp ${LIBC}/deploy/${LIBC}/images/beagleboard/uImage-beagleboard.bin /tmp/EmbErl/uImage
#cp ${LIBC}/deploy/${LIBC}/images/beagleboard/u-boot-beagleboard.bin /tmp/EmbErl/u-boot.bin

cp MLO /tmp/EmbErl/MLO
cp uImage /tmp/EmbErl/uImage
cp u-boot.bin /tmp/EmbErl/u-boot.bin
mv rootfs.tar.bz2 /tmp/EmbErl/

pushd /tmp/EmbErl
${TAR} ${TAR_COMPRESS_BZIP} ${RELEASE}-${LIBC}.tar.bz2 *
popd

cp /tmp/EmbErl/${RELEASE}-${LIBC}.tar.bz2 .

rm -rf /tmp/EmbErl/
