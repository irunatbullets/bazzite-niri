#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# setup niri
dnf5 -y install \
    alacritty \
    at-spi2-core \
    cargo \
    dbus-devel \
    fuzzel \
    mako \
    niri \
    pkgconf-pkg-config \
    rust \
    swaybg \
    swayidle \
    waybar \
    wiremix \
    xwayland-satellite

export CARGO_HOME=/tmp/cargo
export RUSTUP_HOME=/tmp/rustup
export CARGO_INSTALL_ROOT=/usr

cargo install bluetui
cargo install wifitui

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
systemctl --global add-wants niri.service mako.service

mkdir -p /etc/profile.d
cat <<'EOF' > /etc/profile.d/steam_a11y_fix.sh
export STEAM_ENABLE_A11Y=0
EOF
chmod +x /etc/profile.d/steam_a11y_fix.sh

