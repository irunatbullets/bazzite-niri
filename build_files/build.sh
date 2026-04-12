#!/bin/bash

set -euxo pipefail

### Install packages

# NOTE:
# The following "important software" for niri are already installed with gnome
# which comes with the bazzite-gnome base image:
#
# gnome-keyring
# xdg-desktop-portal-gnome
# xdg-desktop-portal-gtk

dnf5 -y install         \
    alacritty           \
    fuzzel              \
    htop                \
    mako                \
    niri                \
    swaybg              \
    swayidle            \
    swaylock            \
    waybar              \
    wiremix             \
    wlogout             \
    xfce-polkit

### Build fresh copies of wifitui, bluetui, and xwayland-satellite
dnf5 -y install rust cargo @development-tools dbus-devel xcb-util-cursor-devel clang git

(
    export CARGO_HOME=/tmp/cargo
    export RUSTUP_HOME=/tmp/rustup
    export CARGO_INSTALL_ROOT=/usr

    # Install wifitui and bluetui
    cargo install wifitui bluetui

    # Build xwayland-satellite from specific commit
    cd /tmp
    git clone https://github.com/Supreeeme/xwayland-satellite.git
    cd xwayland-satellite
    git checkout a879e5e

    cargo build --release

    # Copy binary to same place as cargo install (/usr/bin)
    install -Dm755 target/release/xwayland-satellite /usr/bin/xwayland-satellite
)

### Clean up build artifacts and dev packages
rm -rf /tmp/cargo /tmp/rustup /tmp/xwayland-satellite
dnf5 -y remove rust cargo @development-tools dbus-devel xcb-util-cursor-devel clang git

### Copr install example (in case I forget)
#dnf5 -y copr enable blah/blah
#dnf5 -y install blah
#dnf5 -y copr disable blah/blah

### System Unit Files

systemctl enable podman.socket
systemctl --global add-wants niri.service mako.service
systemctl --global add-wants niri.service swayidle.service

