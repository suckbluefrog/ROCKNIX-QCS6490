# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="go"
PKG_VERSION="1.24.5"
PKG_SHA256="d89da615cb82813b6f725e0a65fd9770aebfcab835c4c91042c4802d6e5a0fb6"
PKG_LICENSE="BSD"
PKG_SITE="https://golang.org"
PKG_URL="https://github.com/golang/go/archive/${PKG_NAME}${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="toolchain"
PKG_LONGDESC="An programming language that makes it easy to build simple, reliable, and efficient software."
PKG_TOOLCHAIN="manual"

configure_host() {
  export GOROOT_FINAL=${TOOLCHAIN}/lib/golang
  if [ -n "${GOROOT_BOOTSTRAP}" ] && [ -x "${GOROOT_BOOTSTRAP}/bin/go" ]; then
    true
  else
    local bootstrap_root=
    local goroot=

    for bootstrap_root in /usr/local/go /usr/lib/go /usr/lib/golang /usr/lib/go-*; do
      if [ -x "${bootstrap_root}/bin/go" ]; then
        export GOROOT_BOOTSTRAP="${bootstrap_root}"
        break
      fi
    done

    if [ -z "${GOROOT_BOOTSTRAP}" ] && command -v go >/dev/null 2>&1; then
      goroot="$(go env GOROOT 2>/dev/null || true)"
      if [ -n "${goroot}" ] && [ -x "${goroot}/bin/go" ]; then
        export GOROOT_BOOTSTRAP="${goroot}"
      fi
    fi
  fi

  if [ -z "${GOROOT_BOOTSTRAP}" ] || [ ! -x "${GOROOT_BOOTSTRAP}/bin/go" ]; then
    cat <<EOF
####################################################################
# Install a Go bootstrap compiler before building this package.
#
# Fedora:
#   sudo dnf install golang
#
# Ubuntu / Debian:
# $ sudo apt install golang-go
# or, on newer Ubuntu releases:
#   sudo apt install golang-1.23-go
#
# You can also export GOROOT_BOOTSTRAP to any existing Go root.
####################################################################
EOF
    return 1
  fi
}

make_host() {
  cd ${PKG_BUILD}/src
  bash make.bash --no-banner
}

pre_makeinstall_host() {
  # need to cleanup old golang version when updating to a new version
  rm -rf ${TOOLCHAIN}/lib/golang
}

makeinstall_host() {
  mkdir -p ${TOOLCHAIN}/lib/golang
  cp -av ${PKG_BUILD}/* ${TOOLCHAIN}/lib/golang/
}
