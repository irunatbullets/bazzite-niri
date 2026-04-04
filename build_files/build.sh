#!/bin/bash

set -euxo pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# Remove kde plasma
dnf5 -y remove plasma-workspace plasma-* kde-* sddm

# Tidy up!
dnf5 -y autoremove

# Setup niri "important software"
dnf5 -y install \
    gnome-keyring \
    mako \
    xfce-polkit \
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
    waybar

# Install rust, cargo and various dependencies
dnf5 -y install \
    rust \
    cargo \
    clang \
    clang-devel \
    dbus-devel \
    pkgconf-pkg-config

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

dnf5 -y install \
    greetd \
    tuigreet

START_NIRI="/usr/local/bin/start-niri"

if [ -L /usr/local ] || [ -e /usr/local ] && [ ! -d /usr/local ]; then
    rm -rf /usr/local
fi

install -d /usr/local/bin

install -Dm755 /dev/stdin "$START_NIRI" <<'EOF'
#!/usr/bin/env bash

cd "$HOME" || exit 1

exec niri-session
EOF

CONFIG_GREETD="/etc/greetd/config.toml"
install -Dm644 /dev/stdin "$CONFIG_GREETD" <<EOF
[terminal]
vt = 1

[default_session]
command = "tuigreet --remember --cmd /usr/local/bin/start-niri"
user = "greetd"
EOF

install -d -o greetd -g greetd -m 0755 /var/cache/tuigreet

git clone https://github.com/jovanlanik/gtklock.git /tmp/gtklock
cd /tmp/gtklock

meson setup build --prefix=/usr --libdir=/usr/lib64
ninja -C build
ninja -C build install

cd /
rm -rf /tmp/gtklock

# Instead of battling cargo dependencies post install, I'm sneaking this in
dnf5 -y install \
    wiremix

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
systemctl enable greetd
systemctl --global add-wants niri.service mako.service
systemctl --global add-wants niri.service swayidle.service
systemctl --global add-wants niri.service xfce-polkit.service

