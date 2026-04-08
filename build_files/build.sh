#!/bin/bash

set -euxo pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# Setup niri "important software" not already covered by gnome.
dnf5 -y install \
    mako \
    mate-polkit \
    xwayland-satellite

# Setup niri
dnf5 -y install \
    alacritty \
    fuzzel \
    niri \
    swaybg \
    swayidle \
    waybar

# Install a couple of tuis
dnf5 -y install \
    htop \
    wiremix

dnf5 -y copr enable binarypie/hypercube
dnf5 -y install \
    bluetui \
    wifitui
dnf5 -y copr disable binarypie/hypercube


# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File
systemctl enable podman.socket
systemctl --global add-wants niri.service mako.service
systemctl --global add-wants niri.service swayidle.service

