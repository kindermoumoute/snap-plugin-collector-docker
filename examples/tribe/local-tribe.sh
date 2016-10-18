#!/bin/bash

set -e
set -u
set -o pipefail

# get the directory the script exists in
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# source the common bash script 
. "${__dir}/../../scripts/common.sh"

# ensure PLUGIN_PATH is set
TMPDIR="/tmp"
PLUGIN_PATH=${PLUGIN_PATH:-"${TMPDIR}/snap/plugins"}
mkdir -p $PLUGIN_PATH
SNAP_LOG_LEVEL=1
SNAP_TRUST_LEVEL=0
snapd --tribe -t ${SNAP_TRUST_LEVEL} -l ${SNAP_LOG_LEVEL} --tribe-node-name node0 >/dev/null 2>&1 &
sleep 2
snapd --tribe -t ${SNAP_TRUST_LEVEL} -l ${SNAP_LOG_LEVEL} --tribe-port 6001 --api-port 8182 --tribe-node-name node1 --tribe-seed 10.241.241.133:6000 --control-listen-port 8083 &
# snapd --tribe -t ${SNAP_TRUST_LEVEL} -l ${SNAP_LOG_LEVEL} --tribe-port 6002 --api-port 8183 --tribe-node-name node2 --tribe-seed 10.241.241.133:6000 --control-listen-port 8084 >/dev/null 2>&1 &
snapd --tribe -t ${SNAP_TRUST_LEVEL} -l ${SNAP_LOG_LEVEL} --tribe-port 6004 --api-port 8185 --tribe-node-name node4 --tribe-seed 10.241.241.133:6000 --control-listen-port 8086 >/dev/null 2>&1  &
snapd --tribe -t ${SNAP_TRUST_LEVEL} -l ${SNAP_LOG_LEVEL} --tribe-port 6005 --api-port 8186 --tribe-node-name node5 --tribe-seed 10.241.241.133:6000 --control-listen-port 8087 >/dev/null 2>&1  &
snapd --tribe -t ${SNAP_TRUST_LEVEL} -l ${SNAP_LOG_LEVEL} --tribe-port 6006 --api-port 8187 --tribe-node-name node6 --tribe-seed 10.241.241.133:6000 --control-listen-port 8088 >/dev/null 2>&1  &
snapd --tribe -t ${SNAP_TRUST_LEVEL} -l ${SNAP_LOG_LEVEL} --tribe-port 6007 --api-port 8188 --tribe-node-name node7 --tribe-seed 10.241.241.133:6000 --control-listen-port 8089 >/dev/null 2>&1  &
snapd --tribe -t ${SNAP_TRUST_LEVEL} -l ${SNAP_LOG_LEVEL} --tribe-port 6008 --api-port 8189 --tribe-node-name node8 --tribe-seed 10.241.241.133:6000 --control-listen-port 8090 >/dev/null 2>&1 &

snapctl agreement create all-nodes
snapctl agreement join all-nodes node0
snapctl agreement join all-nodes node1
# snapctl agreement join all-nodes node2
snapctl agreement join all-nodes node4
snapctl agreement join all-nodes node5
snapctl agreement join all-nodes node6
snapctl agreement join all-nodes node7
snapctl agreement join all-nodes node8
sleep 10
_info `netstat -natp tcp | wc -l`
_info "loading plugins"
snapctl plugin load "${PLUGIN_PATH}/snap-plugin-publisher-file"
_info `netstat -natp tcp | wc -l`
snapctl plugin load "${PLUGIN_PATH}/snap-plugin-collector-mock1"
snapctl metric list
_info `netstat -natp tcp | wc -l`

_info "creating and starting a task"
snapctl task create -t "${__dir}/docker-file.json"

_info `netstat -natp tcp | wc -l`