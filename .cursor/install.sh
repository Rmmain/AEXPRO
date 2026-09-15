#!/usr/bin/env bash
#
# Cloud Agent environment bootstrap for the AEXPRO repository.
#
# AEXPRO is a SwiftUI application for Apple platforms (iOS / macOS / visionOS).
# Building and running the app itself (and the iOS Simulator) requires macOS +
# Xcode, which are not available on a Linux Cloud Agent. This script installs
# the open-source Swift toolchain for Linux so that Swift language tooling is
# available for source-level development, syntax checking, and running any
# platform-agnostic Swift code / swift-testing suites.
#
# The script is idempotent: re-running it will not re-download or re-install an
# already-present toolchain.
set -euo pipefail

SWIFT_VERSION="6.4.0"
SWIFT_PLATFORM="ubuntu24.04"
SWIFT_PLATFORM_DIR="ubuntu2404"
SWIFT_NAME="swift-${SWIFT_VERSION}-RELEASE-${SWIFT_PLATFORM}"
SWIFT_URL="https://download.swift.org/swift-${SWIFT_VERSION}-release/${SWIFT_PLATFORM_DIR}/swift-${SWIFT_VERSION}-RELEASE/${SWIFT_NAME}.tar.gz"
INSTALL_ROOT="/opt/swift"
INSTALL_DIR="${INSTALL_ROOT}/swift-${SWIFT_VERSION}"

echo "==> Installing system dependencies for the Swift toolchain"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends \
  binutils \
  git \
  gnupg2 \
  libc6-dev \
  libcurl4-openssl-dev \
  libedit2 \
  libgcc-13-dev \
  libncurses-dev \
  libpython3-dev \
  libsqlite3-0 \
  libstdc++-13-dev \
  libxml2-dev \
  libz3-dev \
  pkg-config \
  tzdata \
  zip \
  unzip \
  zlib1g-dev

if [ -x "${INSTALL_DIR}/usr/bin/swift" ]; then
  echo "==> Swift ${SWIFT_VERSION} already installed at ${INSTALL_DIR}"
else
  echo "==> Downloading Swift ${SWIFT_VERSION} for ${SWIFT_PLATFORM}"
  sudo mkdir -p "${INSTALL_DIR}"
  tmp_tarball="$(mktemp --suffix=.tar.gz)"
  curl -fSL --retry 4 --retry-delay 4 -o "${tmp_tarball}" "${SWIFT_URL}"
  echo "==> Extracting Swift toolchain to ${INSTALL_DIR}"
  sudo tar xzf "${tmp_tarball}" -C "${INSTALL_DIR}" --strip-components=1
  rm -f "${tmp_tarball}"
fi

echo "==> Registering Swift on PATH via /etc/profile.d/swift.sh"
sudo tee /etc/profile.d/swift.sh >/dev/null <<EOF
export PATH="${INSTALL_DIR}/usr/bin:\${PATH}"
EOF
sudo chmod 0644 /etc/profile.d/swift.sh

export PATH="${INSTALL_DIR}/usr/bin:${PATH}"

echo "==> Swift toolchain version:"
swift --version

echo "==> Environment bootstrap complete"
