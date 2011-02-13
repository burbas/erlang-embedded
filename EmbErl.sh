#!/bin/bash

unset CPATH
unset C_INCLUDE_PATH
unset CPLUS_INCLUDE_PATH
unset OBJC_INCLUDE_PATH
unset LIBS
unset DYLD_FALLBACK_LIBRARY_PATH
unset DYLD_FALLBACK_FRAMEWORK_PATH

export SDKVER="4.2"
export DEVROOT="/Developer/Platforms/iPhoneOS.platform/Developer"
export SDKROOT="$DEVROOT/SDKs/iPhoneOS$SDKVER.sdk"

if [ ! \( -d "$DEVROOT" \) ] ; then
   echo "The iPhone SDK could not be found. Folder \"$DEVROOT\" does not exist."
   exit 1
fi

if [ ! \( -d "$SDKROOT" \) ] ; then
   echo "The iPhone SDK could not be found. Folder \"$SDKROOT\" does not exist."
   exit 1
fi

export PKG_CONFIG_PATH="$SDKROOT/usr/lib/pkgconfig":"/opt/iphone-$SDKVER/lib/pkgconfig":"/usr/local/iphone-$SDKVER/lib/pkgconfig"
export PKG_CONFIG_LIBDIR="$PKG_CONFIG_PATH"
export PREFIX="/opt/iphone-$SDKVER"
export AS="$DEVROOT/usr/bin/as"
export ASCPP="$DEVROOT/usr/bin/as"
export AR="$DEVROOT/usr/bin/ar"
export RANLIB="$DEVROOT/usr/bin/ranlib"
export CPPFLAGS="-miphoneos-version-min=4.1 -std=c99 -pipe -no-cpp-precomp -I$SDKROOT/usr/include -I/opt/iphone-$SDKVER/include -I/usr/local/iphone-$SDKVER/include"
export CFLAGS="-miphoneos-version-min=4.1 -std=c99 -pipe -no-cpp-precomp --sysroot='$SDKROOT' -isystem $SDKROOT/usr/include -isystem /opt/iphone-$SDKVER/include -isystem /usr/local/iphone-$SDKVER/include"
export CXXFLAGS="-miphoneos-version-min=4.1 -std=c99 -pipe -no-cpp-precomp --sysroot='$SDKROOT' -isystem $SDKROOT/usr/include -isystem /opt/iphone-$SDKVER/include -isystem /usr/local/iphone-$SDKVER/include"
export LDFLAGS="-miphoneos-version-min=4.1 -I$SDKROOT/usr/include -I/opt/iphone-$SDKVER/include -I/usr/local/iphone-$SDKVER/include -L$SDKROOT/usr/lib -L/opt/iphone-$SDKVER/lib -L/usr/local/iphone-$SDKVER/lib"
export CPP="$DEVROOT/usr/bin/cpp -E"
export CXXCPP="$DEVROOT/usr/bin/cpp"
export CC="$DEVROOT/usr/bin/arm-apple-darwin10-gcc-4.2.1"
export CXX="$DEVROOT/usr/bin/arm-apple-darwin10-g++-4.2.1"
export LD="$DEVROOT/usr/bin/ld"
export STRIP="$DEVROOT/usr/bin/strip"

################################################################################

PROJECT=EmbErl

VERSION=R14B01
OTP_SRC=otp_src_$VERSION
OTP_SRC_TAR=${OTP_SRC}.tar.gz

XCOMP_CONF=erl-xcomp-arm-darwin.conf
XCOMP_CONF_PATH=xcomp/$XCOMP_CONF

TARGET_ERL_ROOT=/usr/local/erlang

TAR_NAME="EmbErl_"

#standard configuration values
STRIP_BIN=false
STRIP_BEAM=false
SLIM_COMPILE=false
COMPRESS_COMPILE=false
COMPRESS_APP=true

#standard gcc opt levels [1,2,3,s]
OPT_LEVEL=s
HOST=arm-apple-darwin10

#Arguments parsing
while getopts ":scCoH:h" Option
do
    case $Option in
        s ) #echo "Stripping beam and Slim compiles"
            STRIP_BEAM=true
            SLIM_COMPILE=true
            TAR_NAME=${TAR_NAME}s
            ;;
        S ) #echo "Stipping binaries"
            STRIP_BIN=true
            ;;
        c ) #echo "Compress compiling"
            COMPRESS_COMPILE=true
            TAR_NAME=${TAR_NAME}c
            ;;
        C ) #echo "Compressing Applications"
            COMPRESS_APP=true
            TAR_NAME=${TAR_NAME}C
            ;;
        o ) #echo "Optimization level $OPTARG"
            OPT_LEVEL=$OPTARG
            TAR_NAME=${TAR_NAME}o${OPTARG}
            ;;
        H ) #echo "Host $OPTARG"
            HOST=$OPTARG
            TAR_NAME=${TAR_NAME}H-${OPTARG}
            ;;
        h ) echo \
"./Emberl.sh [options]

Available options:
-s          Strip beam files and compile with the slim flag
-c          Compile beams using the compress flag
-C          Compress applications into zip's
-o <arg>    Compile the virtual machine with the <arg> optimization flag
-H <arg>    Compile the virtual machine for the host <arg>
-h          Display this help message "
            exit 0
            ;;
        * ) echo "Unimplemented option chosen."   # DEFAULT 
            ;;
    esac
done

#Create the erl-xcomp configuration
cat $XCOMP_CONF.in > $XCOMP_CONF
sed -i "s/@OPT_LEVEL@/${OPT_LEVEL}/" $XCOMP_CONF
sed -i "s/@HOST@/${HOST}/" $XCOMP_CONF

## FUNCTION DECLARATION SPACE

show()
{
    cat <<EOF

*
* $1...
*

EOF
}

# END OF FUNCTION DECLARATION

WD=$(pwd)

#Do not do unnecessary work
if [ -e ${TAR_NAME}.tgz ]
then
    show "The build exists.. see $TAR_NAME.tgz"
    exit 0
fi

#Download the erlang source if it does not exist.
[ -e $OTP_SRC_TAR ] || (show "Downloading sources" && wget http://erlang.org/download/$OTP_SRC_TAR)

#Unpack
[ -d $OTP_SRC ] || (show "Unpacking $OTP_SRC" && tar xfz $OTP_SRC_TAR)

cp $XCOMP_CONF ${OTP_SRC}/$XCOMP_CONF_PATH


#Enter the Build directory and do configure
#TODO: remove any SKIP files that were created previously
show "Configuring for cross compilation using $XCOMP_CONF_PATH"
pushd $OTP_SRC
./otp_build configure --xcomp-conf=$XCOMP_CONF_PATH

if [[ "$SLIM_COMPILE" == "true" || "$COMPRESS_COMPILE" == "true" ]]
then
    NEW_COMPILE_OPTS=""

    if [ "$SLIM_COMPILE" == "true" ]
    then
        NEW_COMPILE_OPTS="$NEW_COMPILE_OPTS \+slim"
    fi

    if [ "$COMPRESS_COMPILE" == "true" ]
    then
        NEW_COMPILE_OPTS="$NEW_COMPILE_OPTS \+compressed"
    fi

    OTP_MK="make/${HOST}/otp.mk"
    show "Patching $OTP_MK to edit erlc options"
    sed -i "s/ \+debug_info/$NEW_COMPILE_OPTS/" $OTP_MK
fi

#Put SKIP files in the apps we don't want.
show "Selecting applications to keep"
KEEPSIES=$(tr '\n' ' ' < ../keep)
for APP in $(ls lib); do
  echo "Not listed in keep file" >> lib/$APP/SKIP
done
for KEEP in $KEEPSIES; do
  show "Keeping $KEEP"
  rm lib/$KEEP/SKIP
done

show "Creating bootstrap and building"
./otp_build boot

for KEEP in $KEEPSIES; do
  show "Removing prebuilt files in $KEEP"
  rm lib/$KEEP/ebin/*.beam
done

show "Creating release"
./otp_build release

echo $(pwd)

pushd release/${HOST}/ 2> /dev/null || (show "Building release failed!" ; exit 1)

show "Running Install script to setup paths and executables"
./Install -cross -minimal $TARGET_ERL_ROOT
rm Install

if [ $STRIP_BEAM == true ]
then
    show "Stripping beam files"
    erl -eval "beam_lib:strip_release('${WD}/otp_src_R14B01/release/${HOST}')" -s init stop
fi

if [ $STRIP_BIN == true ]
then
    show "Stripping erts binaries"
    ${HOST}-strip erts-*/bin/*
fi

show "Removing source code, documentation, and examples"
for DIR in $(ls | grep erts) lib/*; do
    rm -rf ${DIR}/src
    rm -rf ${DIR}/include
    rm -rf ${DIR}/doc
    rm -rf ${DIR}/man
    rm -rf ${DIR}/examples
done
rm -rf usr/include
rm -rf misc

if [ $COMPRESS_APP = true ]
then
    show "Compressing erlang applications"
    pushd lib
    for APP in $(ls); do
        zip -r ${APP}.zip $APP
        mv ${APP}.zip ${APP}.ez
        rm -f -r $APP
    done
    popd
fi

show "Creating tarball"
tar czf ${WD}/${TAR_NAME}.tgz .

popd
popd
