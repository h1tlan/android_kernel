 #!/bin/bash

LOCALDIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
DEVICE=$1

if [ -z $DEVICE ]; then
    echo DEVICE not set
    exit 1
fi

export ANYKERNEL=/home/h1tlan/Documents/prebuild_Compiler/AnyKernel3

echo USER=$USER
echo LOCALDIR=$LOCALDIR

export ARCH=arm64


echo '[+] Make cleaning...'

rm -rf out/arch/arm64/boot/Image.* out/arch/arm64/boot/dts/*/*.dtbo

echo '[+] Making kernel...'


export PATH="/home/h1tlan/Documents/prebuild_Compiler/linux-x86/clang-r383902/bin:/home/h1tlan/Documents/prebuild_Compiler/aarch64-linux-android-4.9/bin:/home/h1tlan/Documents/prebuild_Compiler/arm-linux-androideabi-4.9/bin:${PATH}"

make ${DEVICE}_defconfig O=out/
make -j$(nproc --all) O=out \
                      CC=clang \
                      LD=ld.lld \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE=aarch64-linux-android- \
                      CROSS_COMPILE_ARM32=arm-linux-androideabi-
                      
                      
                      
if [ $? -eq 0 ]; then
    rm -rf $ANYKERNEL/Image* $ANYKERNEL/zImage* $ANYKERNEL/dt*
    #cp out/arch/arm64/boot/dt.img $ANYKERNEL/
    if [ -f out/arch/arm64/boot/Image.gz-dtb ]; then
    	    cp out/arch/arm64/boot/Image.gz-dtb $ANYKERNEL/
    else
    	if [ -f out/arch/arm64/boot/Image.gz ]; then
    	    cp out/arch/arm64/boot/Image.gz $ANYKERNEL/
    	fi
    fi
    
    #python $LIBUFDT/mkdtboimg.py create out/arch/arm64/boot/dtbo.img out/arch/arm64/boot/dts/*/*.dtbo
    
    if [ -f out/arch/arm64/boot/dtbo.img ]; then
    	cp out/arch/arm64/boot/dtbo.img $ANYKERNEL/
    fi
    
    cd $ANYKERNEL
    export DATE_TIME=`date "+%Y%m%d-%H%M"`
    rm -rf *.zip
    zip -r9 H1tlan_curtana_Kernel-$DATE_TIME.zip * -x .git README.md *placeholder

    echo '[+] Built kernel'
else
    exit 1
fi
exit 0
