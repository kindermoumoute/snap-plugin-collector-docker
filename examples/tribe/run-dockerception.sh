#!/bin/sh

set -e
set -u
set -o pipefail

# PROCFS_MOUNT is the path where /proc will be mounted on the Snap container
PROCFS_MOUNT="${PROCFS_MOUNT:-"/proc_host"}"
SNAP_VERSION="${SNAP_VERSION:-"latest"}"

# define the default plugin folder locations
PLUGIN_SRC="${PLUGIN_SRC:-"$(cd "$(dirname "$0")"/../../ && pwd)"}"
PLUGIN_DEST="${PLUGIN_DEST:-$PLUGIN_SRC}"

# docker-file.sh will download plugins, starts snap, load plugins and start a task
DEFAULT_SCRIPT="${PLUGIN_DEST}/examples/tribe/docker-file.sh && printf \"\n\nhint: type 'snapctl task list'\ntype 'exit' when your done\n\n\" && bash"
RUN_SCRIPT="export SNAP_VERSION=${SNAP_VERSION} && export PROCFS_MOUNT=${PROCFS_MOUNT} && ${RUN_SCRIPT:-$DEFAULT_SCRIPT}"


docker run -it --name dockerception -v ${PLUGIN_SRC}:${PLUGIN_DEST} -v ${PLUGIN_SRC}/../snap/build/linux/x86_64/snapd:/usr/local/bin/snapd -v ${PLUGIN_SRC}/../snap/build/linux/x86_64/snapctl:/usr/local/bin/snapctl --entrypoint=${PLUGIN_DEST}/examples/tribe/docker-file.sh intelsdi/snap:alpine
docker rm dockerception