#!/bin/bash -e

export SG_BOARD_FAMILY=sg200x
export SG_BOARD_LINK=sg2002_licheervnano_sd

sdkver=keep
tpusdk=y
while [ "$#" -gt 0 ]; do
	case "$1" in
	--board=*|--board-link=*)
		export SG_BOARD_LINK=`echo $1 | cut -d '=' -f 2-`
		shift
		;;
	--sdk-ver=*|--sdkver=*)
		sdkver=`echo $1 | cut -d '=' -f 2-`
		shift
		;;
	*)
		break
		;;
	esac
done

for p in / /usr/ /usr/local/ ; do
  if echo $PATH | grep -q ${p}bin ; then
    if ! echo $PATH | grep -q ${p}sbin ; then
      export PATH=${p}sbin:$PATH
    fi
  fi
done

if echo ${SG_BOARD_LINK} | grep -q -E '^cv180' ; then
  export SG_BOARD_FAMILY=cv180x
fi
if echo ${SG_BOARD_LINK} | grep -q -E '^sg200' ; then
  export SG_BOARD_FAMILY=sg200x
fi

sdkcros=linux-gnu
sdklibc=`echo $sdkver | cut -d '_' -f 1`
sdkarch=`echo $sdkver | cut -d '_' -f 2`
sdktool=`echo $sdkver | tr a-z A-Z`
oldcros=$sdkcros
oldlibc=$sdklibc
oldarch=$sdkarch
# Allow to switch from ARM 32-bit to 64-bit and vice versa
if [ $sdkver = glibc_arm64 ]; then
  oldarch=arm
elif [ $sdkver = glibc_arm ]; then
  oldarch=arm64
fi
# Allow to switch from RISC-V musl to glibc and vice versa
if [ $sdkver = musl_riscv64 ]; then
  sdkcros=linux-musl
  oldlibc=glibc
elif [ $sdkver = glibc_riscv64 ]; then
  oldcros=linux-musl
  oldlibc=musl
fi
oldtool=`echo ${oldlibc}_${oldarch} | tr a-z A-Z`
[ $oldarch = riscv64 ] && oldarch=riscv
[ $sdkarch = riscv64 ] && sdkarch=riscv

cd build
if [ $sdkcros != $oldcros ]; then
  sed -i s/'-unknown-'${oldcros}'-'/'-unknown-'${sdkcros}'-'/g boards/${SG_BOARD_FAMILY}/${SG_BOARD_LINK}/${SG_BOARD_LINK}_defconfig
fi
if [ $sdktool != $oldtool ]; then
  if ! grep -q -E '^CONFIG_TOOLCHAIN_.*=y' boards/${SG_BOARD_FAMILY}/${SG_BOARD_LINK}/${SG_BOARD_LINK}_defconfig ; then
    echo 'CONFIG_TOOLCHAIN_'${sdktool}'=y' >> boards/${SG_BOARD_FAMILY}/${SG_BOARD_LINK}/${SG_BOARD_LINK}_defconfig
  else
    sed -i s/'^CONFIG_TOOLCHAIN_'${oldtool}'=y'/'CONFIG_TOOLCHAIN_'${sdktool}'=y'/g boards/${SG_BOARD_FAMILY}/${SG_BOARD_LINK}/${SG_BOARD_LINK}_defconfig
  fi
fi
if [ $sdkarch != $oldarch ]; then
  if ! grep -q -E '^CONFIG_ARCH=".*"' boards/${SG_BOARD_FAMILY}/${SG_BOARD_LINK}/${SG_BOARD_LINK}_defconfig ; then
    echo 'CONFIG_ARCH="'${sdkarch}'"' >> boards/${SG_BOARD_FAMILY}/${SG_BOARD_LINK}/${SG_BOARD_LINK}_defconfig
  else
    sed -i s/'^CONFIG_ARCH="'${oldarch}'"'/'CONFIG_ARCH="'${sdkarch}'"'/g boards/${SG_BOARD_FAMILY}/${SG_BOARD_LINK}/${SG_BOARD_LINK}_defconfig
  fi
  [ -e boards/${SG_BOARD_FAMILY}/${SG_BOARD_LINK}/dts_${oldarch} -a \
  ! -e boards/${SG_BOARD_FAMILY}/${SG_BOARD_LINK}/dts_${sdkarch} ] && ln -s dts_${oldarch} boards/${SG_BOARD_FAMILY}/${SG_BOARD_LINK}/dts_${sdkarch}
fi
cd ..

source build/cvisetup.sh
defconfig ${SG_BOARD_LINK}

if [ -e cviruntime -a -e flatbuffers ]; then
  # small fix to keep fork of flatbuffers repository optional
  sed -i s/'-Werror=unused-parameter"'/'-Werror=unused-parameter -Wno-class-memaccess"'/g flatbuffers/CMakeLists.txt
  # fix "fatal error: Can't find suitable multilib set"
  sed -i s/'-march=rv64imafdcvxthead -mcmodel=medany -mabi=lp64dv'/'-march=rv64imafdcv0p7xthead -mcmodel=medany -mabi=lp64d'/g cvi_rtsp/Makefile.inc
  [ $tpusdk = y ] && export TPU_REL=1
fi

function build_sdks()
{(
  if [ ! -e middleware/lib/libcvi_bin.so ]; then
    if [ ! -e u-boot-2021.10/build/sg2002_licheervnano_sd/tools/mkimage ]; then
      # kernel needs mkimage
      build_uboot || return $?
    fi
    # osdrv needs kernel headers
    build_kernel || return $?
    #build_ramboot || return $?
    # middleware needs osdrv headers
    build_osdrv || return $?
  fi
  if [ ! -e middleware/lib/libcvi_bin.so ]; then
    # sdk needs middleware libs
    build_middleware || return $?
  fi
  build_3rd_party || return $?
  if [ "$TPU_REL" = 1 ]; then
    build_tpu_sdk || return $?
    build_ive_sdk || return $?
    build_ivs_sdk || return $?
    build_ai_sdk  || return $?
  fi
)}

build_sdks

echo OK
