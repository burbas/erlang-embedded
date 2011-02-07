#!/bin/bash

#TODO add interface for usb0
#TODO add embedded erlang logo

#Small scripts to prepear a release tar, run with root priviledges

RELEASE="harbor-seal"

TAR=tar #Use gnutar for mac
TAR_EXTRACT_BZIP="xjf"
TAR_EXTRACT_GZ="xzf"
TAR_COMPRESS_BZIP="cfj"
TARGET_ERL_ROOT=/opt/local/erlang/

LIBC=$1

generate_welcome_screen()
{
    cat <<EOF
 _____       _         _   _       _     _____     _
|   __|_____| |_ ___ _| |_| |___ _| |___|   __|___| |___ ___ ___
|   __|     | . | -_| . | . | -_| . |___|   __|  _| | .'|   | . |
|_____|_|_|_|___|___|___|___|___|___|   |_____|_| |_|__,|_|_|_  |
                                                            |___|
 _____
|     |___ ___ ___
|   --| . |  _| -_|
|_____|___|_| |___|

The Embedded Erlang Distribution

${RELEASE} \n \l
EOF
}

mkdir -p /tmp/EmbErl/opt/local/erlang

${TAR} ${TAR_EXTRACT_BZIP} ${LIBC}/deploy/${LIBC}/images/beagleboard/minimalist-image-beagleboard.tar.bz2 -C /tmp/EmbErl/

${TAR} ${TAR_EXTRACT_GZ} erlang-${RELEASE}.tgz -C /tmp/EmbErl/${TARGET_ERL_ROOT}

generate_welcome_screen > /tmp/EmbErl/etc/issue

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
