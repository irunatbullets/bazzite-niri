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

### Copr installs

dnf5 -y copr enable binarypie/hypercube
dnf5 -y install         \
    bluetui             \
    wifitui
dnf5 -y copr disable binarypie/hypercube

### System Unit Files

systemctl enable podman.socket
systemctl --global add-wants niri.service mako.service
systemctl --global add-wants niri.service swayidle.service

