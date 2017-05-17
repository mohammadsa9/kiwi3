#!/bin/bash

# Custom Kernel build script
# Special thanks to GuneetAtwal for his great build script and kernel for kiwi
# Constants
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
cyan='\033[0;36m'
yellow='\033[0;33m'
blue='\033[0;34m'
default='\033[0m'

# Resources
ANDROID_DIR=~/android
KERNEL_DIR=$PWD
IMAGE=$KERNEL_DIR/arch/arm64/boot/Image
#IMAGE=$KERNEL_DIR/arch/arm/boot/zImage for 32 bit architecture
DTBTOOL=$KERNEL_DIR/scripts/dtbTool
TOOLCHAIN=$ANDROID_DIR/linaro6/bin

#Paths
OUT_DIR=$KERNEL_DIR/out
OUT_ZIP=$KERNEL_DIR/Releases
NEW_OUT=$OUT_DIR/tools

# Kernel Version Info
BASE="-HotDoG™"
CUR_VER="-x"
HD_VER="$BASE$CUR_VER"
 

# Variables

DEFCONFIG="hd_defconfig"
export LOCALVERSION=~`echo $HD_VER`
export CROSS_COMPILE=$TOOLCHAIN/aarch64-linux-android-
export ARCH=arm64
export KBUILD_BUILD_USER="mohammadsa9"
export KBUILD_BUILD_HOST="kiwi"

function make_hd {
		echo -e "$green*******************************************************"
		echo "                  Compiling $HD_VER	              "
		echo -e "*****************************************************"
		echo
		make $DEFCONFIG
		make menuconfig
		make -j9
		rm -rf $NEWOUT/Image
		cp -vr $IMAGE $NEW_OUT
		make_dtb
		make_zip
		housekeeping
		echo -e "$green*******************************************************"
		echo "              Compilation Completed!!              "
		echo -e "*****************************************************$default"
		}
		
function make_clean {
		echo -e "$green***********************************************"
		echo "          Cleaning up object files and other stuff	              "
		echo -e "***********************************************$default"
		make mrproper
		make_hd
	}
		
function make_recompile {
			echo -e "$cyan*******************************************************"
			echo "             Recompiling $HD_VER	              "
			echo -e "*****************************************************"
			make -j8
			rm -rf $NEWOUT/Image
			cp -vr $IMAGE $NEW_OUT
			make_dtb
			make_zip
			housekeeping
		}
		
function make_dtb {
			echo -e "$blue*******************************************************"
			echo "             		Creating dt.img....	              "
			echo -e "*****************************************************"
			rm -rf $NEWOUT/dt.img
			$DTBTOOL -v -s 2048 -o $NEW_OUT/dt.img -p scripts/dtc/ arch/arm64/boot/dts/
		}

function make_zip {
		echo -e "$yellow*******************************************************"
		echo "             		Zipping up....	              "
		echo -e "*****************************************************"
		cd $OUT_DIR
		rm -f '*.zip'
		zip -yr HDKernel`echo $CUR_VER`.zip *
		mv HDKernel`echo $CUR_VER`.zip $OUT_ZIP
		echo "       Find your zip in Releases directory"
		echo -e "$default"
		cd $KERNEL_DIR 
		}

function housekeeping {
		echo -e "$green*******************************************************"
		echo "            Cleaning up the mess created...	              "
		echo -e "*****************************************************$default"
		rm -rf $NEW_OUT/Image
		rm -rf $NEW_OUT/dt.img
	}
		

BUILD_START=$(date +"%s")
while read -p " 'Y' to Compile all , 'R' to clean and recompile , 'C' to to do a clean compilation 'N' to exit " choice
do
case "$choice" in
	y|Y)
		make_hd
		break
		;;
	r|R )
		make_recompile
		break
		;;
	c|C )
		make_clean
		break;
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Wrong input"
		echo
		;;
esac
done
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$green Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$default"

