# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="AIC8800"
PKG_VERSION="9472567f729ef9f477098ebcd0751e0d65326b72"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/radxa-pkg/aic8800"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="AIC8800 USB WLAN driver and firmware"
PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"

AIC8800_PATCHES="\
  fix-usb-firmware-path.patch \
  fix-linux-6.1-build.patch \
  fix-linux-6.5-build.patch \
  fix-linux-6.7-build.patch \
  fix-linux-6.9-build.patch \
  fix-linux-6.13-build.patch \
  fix-linux-6.14-build.patch \
  fix-linux-6.15-build.patch \
  fix-linux-6.16-build.patch \
  fix-usb-build.patch \
  fix-linux-6.17-build.patch"

pre_make_target() {
  unset LDFLAGS

  if [ ! -f "${PKG_BUILD}/.rocknix-aic8800-prepared" ]; then
    # Radxa ships both the driver sources and their Debian patch set with CRLF endings.
    # Normalize them first so the upstream compatibility patches apply cleanly.
    find "${PKG_BUILD}/src" -type f \( -name '*.[ch]' -o -name Makefile -o -name Kconfig \) \
      -exec sed -i 's/\r$//' {} +
    sed -i 's/\r$//' "${PKG_BUILD}"/debian/patches/*.patch "${PKG_BUILD}"/debian/patches/series

    for PATCH in ${AIC8800_PATCHES}; do
      (cd "${PKG_BUILD}" && patch -p1 < "debian/patches/${PATCH}")
    done

    touch "${PKG_BUILD}/.rocknix-aic8800-prepared"
  fi
}

make_target() {
  kernel_make -C $(kernel_path) M="${PKG_BUILD}/src/USB/driver_fw/drivers/aic8800"
}

makeinstall_target() {
  MODULE_DIR="${INSTALL}/$(get_full_module_dir)/kernel/drivers/net/wireless/aic8800"
  FW_DIR="${INSTALL}/$(get_full_firmware_dir)/aic8800_fw/USB"

  mkdir -p "${MODULE_DIR}"
  cp "${PKG_BUILD}/src/USB/driver_fw/drivers/aic8800/aic_load_fw/aic_load_fw.ko" "${MODULE_DIR}/"
  cp "${PKG_BUILD}/src/USB/driver_fw/drivers/aic8800/aic8800_fdrv/aic8800_fdrv.ko" "${MODULE_DIR}/"

  mkdir -p "${FW_DIR}"
  cp -a "${PKG_BUILD}/src/USB/driver_fw/fw/." "${FW_DIR}/"
}
