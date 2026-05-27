#!/bin/bash

set -euxo pipefail

IMAGE_NAME="${IMAGE_NAME:-bazzite-niri}"
IMAGE_VARIANT="${IMAGE_VARIANT:-}"

if [ -z "$IMAGE_VARIANT" ]; then
    FULL_NAME="$IMAGE_NAME"
else
    FULL_NAME="${IMAGE_NAME}-${IMAGE_VARIANT}"
fi

IMAGE_REF="ostree-image-signed:docker://ghcr.io/irunatbullets/${FULL_NAME}"

dnf5 -y install         \
    alacritty           \
    fuzzel              \
    grim                \
    htop                \
    mako                \
    niri                \
    swaybg              \
    slurp               \
    swayidle            \
    swaylock            \
    waybar              \
    wiremix             \
    wlogout             \
    xfce-polkit

dnf5 -y install rust cargo @development-tools dbus-devel xcb-util-cursor-devel clang git
(
    export CARGO_HOME=/tmp/cargo
    export RUSTUP_HOME=/tmp/rustup
    export CARGO_INSTALL_ROOT=/usr

    cargo install wifitui bluetui

    cd /tmp
    git clone https://github.com/Supreeeme/xwayland-satellite.git
    cd xwayland-satellite
    git checkout a879e5e

    cargo build --release

    install -Dm755 target/release/xwayland-satellite /usr/bin/xwayland-satellite
)
rm -rf /tmp/cargo /tmp/rustup /tmp/xwayland-satellite
dnf5 -y remove rust cargo @development-tools dbus-devel xcb-util-cursor-devel clang git

systemctl enable podman.socket
systemctl --global add-wants niri.service mako.service
systemctl --global add-wants niri.service swayidle.service

jq \
    --arg name "$FULL_NAME" \
    --arg ref "$IMAGE_REF" \
    --arg tag "${IMAGE_VARIANT:-latest}" \
    '
    .["image-name"]=$name |
    .["image-ref"]=$ref |
    .["image-tag"]=$tag
    ' \
    /usr/share/ublue-os/image-info.json \
    > /tmp/image-info.json && mv /tmp/image-info.json /usr/share/ublue-os/image-info.json

