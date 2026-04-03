#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# Remove kde plasma
dnf5 -y remove plasma-workspace plasma-* kde-* sddm

# Remove existing bazzite pipewire stuff
dnf5 versionlock delete \
    pipewire \
    pipewire-alsa \
    pipewire-gstreamer \
    pipewire-jack-audio-connection-kit \
    pipewire-jack-audio-connection-kit-libs \
    pipewire-libs \
    pipewire-plugin-libcamera \
    pipewire-pulseaudio \
    pipewire-utils \
    wireplumber \
    wireplumber-libs

# Tidy up!
dnf5 -y autoremove

# Install pipewire
dnf5 -y install \
    pipewire \
    pipewire-libs \
    pipewire-devel

# Setup niri "important software"
dnf5 -y install \
    gnome-keyring \
    xfce-polkit \
    mako \
    nautilus \
    xdg-desktop-portal-gnome \
    xdg-desktop-portal-gtk \
    xwayland-satellite

# Setup niri
dnf5 -y install \
    alacritty \
    fuzzel \
    niri \
    swaybg \
    swayidle \
    swaylock \
    waybar

# Install rust, cargo and various dependencies
dnf5 -y install \
    rust \
    cargo \
    dbus-devel \
    pkgconf-pkg-config

dnf5 -y install \
    tuigreet

# Build gtklock from source
dnf5 -y install \
    meson \
    ninja \
    gcc \
    gtk3-devel \
    pam-devel \
    wayland-devel \
    wayland-protocols-devel \
    gobject-introspection-devel \
    vala

git clone https://github.com/jovanlanik/gtklock.git /tmp/gtklock
cd /tmp/gtklock

meson setup build --prefix=/usr --libdir=/usr/lib64
ninja -C build
ninja -C build install

cd /
rm -rf /tmp/gtklock

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
systemctl --global add-wants niri.service xfce-polkit.service

