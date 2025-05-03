#!/bin/bash

abort()
{
    cd -
    echo "-----------------------------------------------"
    echo "Kernel compilation failed! Exiting..."
    echo "-----------------------------------------------"
    exit -1
}

unset_flags()
{
    cat << EOF
Usage: $(basename "$0") [options]
Options:
    -m, --model [value]    Specify the model code of the phone
    -k, --ksu [y/N]        Include KernelSU
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --model|-m)
            MODEL="$2"
            shift 2
            ;;
        --ksu|-k)
            KSU_OPTION="$2"
            shift 2
            ;;
        *)\
            unset_flags
            exit 1
            ;;
    esac
done

echo "Preparing the build environment..."

SECONDS=0

pushd $(dirname "$0") > /dev/null
CORES=`cat /proc/cpuinfo | grep -c processor`

# Define toolchain variables
CLANG_DIR=$PWD/toolchain/clang-r416183b
GCC_DIR=$PWD/toolchain/gcc_4.9
PATH=$CLANG_DIR/bin:$CLANG_DIR/lib:$GCC_DIR/bin:$GCC_DIR/lib:$PATH

MAKE_ARGS="
LLVM=1 \
LLVM_IAS=1 \
ARCH=arm64 \
READELF=$CLANG_DIR/bin/llvm-readelf \
CROSS_COMPILE=$GCC_DIR/bin/aarch64-linux-gnu- \
O=out
"

# Define specific variables
case $MODEL in
r0s)
    KERNEL_DEFCONFIG=s5e9925-r0sxxx_defconfig
    BOARD=SRPUH13A011
;;
g0s)
    KERNEL_DEFCONFIG=s5e9925-g0sxxx_defconfig
    BOARD=SRPUG08A011
;;
b0s)
    KERNEL_DEFCONFIG=s5e9925-b0sxxx_defconfig
    BOARD=SRPUH13B009
;;
*)
    unset_flags
    exit
esac

if [ -z $KSU_OPTION ]; then
    read -p "Include KernelSU (y/N): " KSU_OPTION
fi

if [[ "$KSU_OPTION" == "y" ]]; then
    KSU=ksu.config
fi

rm -rf build/out/$MODEL
mkdir -p build/out/$MODEL/zip/files
mkdir -p build/out/$MODEL/zip/META-INF/com/google/android

build_kernel() {
    # Build kernel image
    echo "-----------------------------------------------"
    echo "Defconfig: "$KERNEL_DEFCONFIG""

    if [ -z "$KSU" ]; then
        echo "KSU: N"
    else
        echo "KSU: $KSU"
    fi

    echo "-----------------------------------------------"
    echo "Building kernel using "$KERNEL_DEFCONFIG""
    echo "Generating configuration file..."
    echo "-----------------------------------------------"
    make ${MAKE_ARGS} -j$CORES $KERNEL_DEFCONFIG $KSU || abort

    echo "Building kernel..."
    echo "-----------------------------------------------"
    make ${MAKE_ARGS} -j$CORES || abort
}

build_boot() {
    echo "-----------------------------------------------"
    echo "Building boot.img RAMDisk..."
    mkdir -p build/out/$MODEL/boot_ramdisk00

    # Copy common files for boot.img's RAMDisk
    cp -a build/ramdisk/boot/boot_ramdisk00 build/out/$MODEL
    
    # Copy device build.prop file for boot.img's RAMDisk
    cp -a build/ramdisk/boot/device/$MODEL/* build/out/$MODEL/boot_ramdisk00/system/etc/ramdisk

    pushd build/out/$MODEL/boot_ramdisk00 > /dev/null
    find . ! -name . | LC_ALL=C sort | cpio -o -H newc -R root:root | lz4 -l > ../boot_ramdisk || abort
    popd > /dev/null

    echo "-----------------------------------------------"
    echo "Building boot.img..."

    cp -a out/arch/arm64/boot/Image build/out/$MODEL

    OUTPUT_FILE=build/out/$MODEL/boot.img
    RAMDISK_00=build/out/$MODEL/boot_ramdisk
    KERNEL=build/out/$MODEL/Image
    HEADER_VERSION=4
    OS_VERSION=14.0.0
    OS_PATCH_LEVEL=2024-08
    CMDLINE=""

	python3 toolchain/mkbootimg/mkbootimg.py --header_version $HEADER_VERSION --cmdline "$CMDLINE" --ramdisk $RAMDISK_00 \
	--os_version $OS_VERSION --os_patch_level $OS_PATCH_LEVEL --kernel $KERNEL --output $OUTPUT_FILE || abort
}

build_dtb() {
    echo "-----------------------------------------------"
    echo "Building DTB image..."
    ./toolchain/mkdtimg cfg_create build/out/$MODEL/dtb.img build/dtconfigs/s5e9925.cfg -d out/arch/arm64/boot/dts/exynos || abort 

    echo "-----------------------------------------------"
    echo "Building DTBO image..."
    ./toolchain/mkdtimg cfg_create build/out/$MODEL/dtbo.img build/dtconfigs/$MODEL.cfg -d out/arch/arm64/boot/dts/samsung/$MODEL || abort
    
}

build_modules() {
    MODULES_FOLDER=modules
    rm -rf out/$MODULES_FOLDER

    echo "-----------------------------------------------"
    echo "Building modules..."
    # Strip modules and place them in modules folder
    make ${MAKE_ARGS} INSTALL_MOD_PATH=$MODULES_FOLDER INSTALL_MOD_STRIP=1 modules_install || abort

    # List of kernel modules to remove
    # Some of the kernel modules are in /vendor_dlkm or /vendor/lib/modules and not in vendor_boot
    # So we will remove them from the folder and run depmod again to update the files
    # TODO: Generate a /vendor_dlkm partition as well
    # The filenames were fetched from vendor_module_list_s5e9925.cfg and vendor_module_list_s5e9925_b0s.cfg.
    FILENAMES="
    sec_debug_coredump.ko
    fingerprint.ko
    fingerprint_sysfs.ko
    input_booster_lkm.ko
    dhd.ko
    wlan.ko
    "
    for FILENAME in $FILENAMES; do
        FILE=$(find out/$MODULES_FOLDER -type f -name "$FILENAME")
        echo "$FILE" | xargs rm -f
    done

    # Now we run depmod to update the dep/softdep files
    # For this we need the kernel version
    KERNEL_DIR_PATH=$(find "out/$MODULES_FOLDER/lib/modules" -maxdepth 1 -type d -name "5.10*") || abort
    KERNEL_VERSION=$(basename $KERNEL_DIR_PATH) || abort

    # And finally depmod itself
    depmod -a -b out/$MODULES_FOLDER $KERNEL_VERSION || abort

    # depmod updates modules.alias, modules.dep and modules.softdep
    # But the module order is not updated by depmod
    # We have to remove the filenames ourselves
    # But first, our vendor_boot needs modules.order definitions that go like:
    # fingerprint.ko
    # Clang generates modules.order definitions like this
    # kernel/drivers/fingerprint/fingerprint.ko
    # So we sed the file to adapt
    sed -i 's/.*\///g' $KERNEL_DIR_PATH/modules.order 

    # Now we sed the bad filenames out of the file with a loop
    for FILENAME in $FILENAMES; do
        sed -i "/$FILENAME/d" "$KERNEL_DIR_PATH/modules.order"
    done

    # Now we have to order the modules
    # Samsung was nice enough to give us the order in vendor_boot_module_order_s5e9925.cfg
    # exynos-chipid_v2.ko exynos-reboot.ko sec_debug_base_early.ko clk_exynos.ko exynos_mct_v2.ko s3c2410_wdt.ko sec_debug_mode.ko
    # These files have to be at the top of modules.order in this order, and then we can keep the default order.
    # Samsung wants the file to be renamed to modules.load anyways, so we will craft our own modules.load file based on modules.order
    touch $KERNEL_DIR_PATH/modules.load

    INITIAL_ORDER="
    exynos-chipid_v2.ko
    exynos-reboot.ko
    sec_debug_base_early.ko
    clk_exynos.ko
    exynos_mct_v2.ko
    s3c2410_wdt.ko
    sec_debug_mode.ko
    "

    # First we add the order from Samsung into our new modules.load
    # And we sed it out of modules.order
    for LINE in $INITIAL_ORDER; do
        echo $LINE >> $KERNEL_DIR_PATH/modules.load
        sed -i "/$LINE/d" "$KERNEL_DIR_PATH/modules.order"
    done

    # Now we add the remaining lines from modules.order into modules.load
    while IFS= read -r line; do
        echo "$line" >> "$KERNEL_DIR_PATH/modules.load"
    done < "$KERNEL_DIR_PATH/modules.order"

    # Now we have to also modify modules.dep
    # Android generates them like this
    # kernel/drivers/dma/samsung-dma.ko: kernel/drivers/dma/pl330.ko
    # But Samsung wants them like this
    # /lib/modules/samsung-dma.ko: /lib/modules/pl330.ko
    # So we will format it with sed
    sed -i 's/\(kernel\/[^: ]*\/\)\([^: ]*\.ko\)/\/lib\/modules\/\2/g' "$KERNEL_DIR_PATH/modules.dep"

    # Now the modules and their configuration descriptor files are ready, we move them to a folder and create the new second ramdisk
    # The second ramdisk should contain a /lib/modules where the modules are located
    mkdir -p build/out/$MODEL/modules/lib/modules

    find $KERNEL_DIR_PATH -name '*.ko' -exec cp '{}' build/out/$MODEL/modules/lib/modules ';'

    # We also copy the module configuration descriptors
    cp $KERNEL_DIR_PATH/modules.{alias,dep,softdep,load} build/out/$MODEL/modules/lib/modules
}

build_vendor_boot() {
    echo "-----------------------------------------------"
    echo "Building vendor_boot RAMDisks..."
    # Copy common vendor_ramdisk00 files to build/out
    cp -a build/ramdisk/vendor_boot/ramdisk00 build/out/$MODEL/vendor_ramdisk00
    
    # Copy device firmware files for vendor_ramdisk00
    cp -a build/ramdisk/vendor_boot/vendor_firmware/$MODEL/* build/out/$MODEL/vendor_ramdisk00

    # Pack RAMDisks
    # vendor_ramdisk == ramdisk00
    # modules_ramdisk == ramdisk01
    pushd build/out/$MODEL/vendor_ramdisk00 > /dev/null
    find . ! -name . | LC_ALL=C sort | cpio -o -H newc -R root:root | lz4 -l > ../$MODEl/vendor_ramdisk || abort
    popd > /dev/null

    pushd build/out/$MODEL/modules > /dev/null
    find . ! -name . | LC_ALL=C sort | cpio -o -H newc -R root:root | lz4 -l > ../modules_ramdisk || abort
    popd > /dev/null

    echo "-----------------------------------------------"
    echo "Building vendor_boot image..."

    OUTPUT_FILE=build/out/$MODEL/vendor_boot.img
    DTB_PATH=build/out/$MODEL/dtb.img
    BOOTCONFIG_PATH=build/ramdisk/bootconfig
    RAMDISK_00=build/out/$MODEL/vendor_ramdisk
    RAMDISK_01=build/out/$MODEL/modules_ramdisk
    HEADER_VERSION=4
    BASE=0x00000000
    PAGESIZE=0x00001000
    KERNEL_OFFSET=0x10008000
    RAMDISK_OFFSET=0x14000000
    TAGS_OFFSET=0x10000000
    DTB_OFFSET=0x0000000011F00000
    CMDLINE="bootconfig loop.max_part=7"

    python3 toolchain/mkbootimg/mkbootimg.py --header_version $HEADER_VERSION --pagesize $PAGESIZE --base $BASE --kernel_offset $KERNEL_OFFSET \
	--ramdisk_offset $RAMDISK_OFFSET --tags_offset $TAGS_OFFSET --dtb_offset $DTB_OFFSET --vendor_cmdline "$CMDLINE" --board $BOARD --dtb $DTB_PATH  \
	--ramdisk_type 1 --ramdisk_name "" --vendor_ramdisk_fragment $RAMDISK_00 --vendor_bootconfig $BOOTCONFIG_PATH --ramdisk_type 3 \
	--ramdisk_name dlkm --vendor_ramdisk_fragment $RAMDISK_01 --vendor_boot $OUTPUT_FILE || abort
}

build_zip() {
    echo "-----------------------------------------------"
    echo "Building zip..."
    cp build/out/$MODEL/boot.img build/out/$MODEL/zip/files/boot.img
    cp build/out/$MODEL/vendor_boot.img build/out/$MODEL/zip/files/vendor_boot.img
    cp build/out/$MODEL/dtbo.img build/out/$MODEL/zip/files/dtbo.img
    cp build/update-binary build/out/$MODEL/zip/META-INF/com/google/android/update-binary
    cp build/updater-script-$MODEL build/out/$MODEL/zip/META-INF/com/google/android/updater-script

    version=$(grep -o 'CONFIG_LOCALVERSION="[^"]*"' arch/arm64/configs/$KERNEL_DEFCONFIG | cut -d '"' -f 2)
    version=${version:1}
    pushd build/out/$MODEL/zip > /dev/null
    DATE=`date +"%d-%m-%Y_%H-%M-%S"`

    if [[ "$KSU_OPTION" == "y" ]]; then
        NAME="$version"_"$MODEL"_UNOFFICIAL_KSU_"$DATE".zip
    else
        NAME="$version"_"$MODEL"_UNOFFICIAL_"$DATE".zip
    fi
    zip -r -qq ../"$NAME" .
    popd > /dev/null
}

build_kernel
build_boot
build_dtb
build_modules
build_vendor_boot
build_zip

popd > /dev/null

duration=$SECONDS
echo "-----------------------------------------------"
echo "Build finished successfully in $(($duration / 60)) minutes and $(($duration % 60)) seconds"
echo "-----------------------------------------------"