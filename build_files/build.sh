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
    xfce-polkit         \
    xwayland-satellite

### Copr installs

dnf5 -y copr enable gierth/tools-rust
dnf5 -y install         \
    bluetui             \
    impala              \
    wiremix
dnf5 -y copr disable gierth/tools/rust

### System Unit Files

systemctl enable podman.socket
systemctl --global add-wants niri.service mako.service
systemctl --global add-wants niri.service swayidle.service

