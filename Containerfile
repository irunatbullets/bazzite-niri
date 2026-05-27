ARG BASE_IMAGE=ghcr.io/ublue-os/bazzite-gnome:stable

FROM scratch AS buildctx
COPY build_files /ctx/

FROM ${BASE_IMAGE} AS base

COPY services /usr/lib/systemd/user/

RUN --mount=type=bind,from=buildctx,source=/ctx,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint

