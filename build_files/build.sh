#!/bin/bash

set -euxo pipefail

### Install packages
dnf5 -y install         \
    alacritty           \
    fuzzel              \
    htop                \
    mako                \
    niri                \
    swaybg              \
    swayidle            \
    waybar              \
    wiremix             \
    xfce-polkit         \
    xwayland-satellite

### Build fresh copies of wifitui and bluetui
dnf5 -y install rust cargo @development-tools dbus-devel
(
    export CARGO_HOME=/tmp/cargo
    export RUSTUP_HOME=/tmp/rustup
    export CARGO_INSTALL_ROOT=/usr

    cargo install wifitui bluetui
)

###  Clean up build artifacts and dev packages
rm -rf /tmp/cargo /tmp/rustup
dnf5 -y remove rust cargo @development-tools dbus-devel

### Copr example (because I will probably forget how this works)
#dnf5 -y copr enable blah/blah
#dnf5 -y install blah
#dnf5 -y copr disable blah/blah

### System Unit Files

systemctl enable podman.socket
systemctl --global add-wants niri.service mako.service
systemctl --global add-wants niri.service swayidle.service

