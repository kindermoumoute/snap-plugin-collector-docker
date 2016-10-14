#!/bin/bash

set -e
set -u
set -o pipefail

# get the directory the script exists in
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# source the common bash script 
. "${__dir}/../../scripts/common.sh"

# ensure PLUGIN_PATH is set
TMPDIR=${TMPDIR:-"/tmp"}
PLUGIN_PATH=${PLUGIN_PATH:-"${TMPDIR}/snap/plugins"}
mkdir -p $PLUGIN_PATH
SNAP_LOG_LEVEL=5
# install_snap
mkdir -p /opt/snap/bin
mkdir -p /opt/snap/plugins
mkdir -p /var/log/snap
mkdir -p /etc/snap
snapd --tribe -t ${SNAP_TRUST_LEVEL} -l ${SNAP_LOG_LEVEL} --tribe-node-name node0 &
sleep 2
snapd --tribe -t ${SNAP_TRUST_LEVEL} -l ${SNAP_LOG_LEVEL} --tribe-port 6001 --api-port 8182 --tribe-node-name node1 --tribe-seed 172.17.0.2:6000 --control-listen-port 8083 &
snapd --tribe -t ${SNAP_TRUST_LEVEL} -l ${SNAP_LOG_LEVEL} --tribe-port 6002 --api-port 8183 --tribe-node-name node2 --tribe-seed 172.17.0.2:6000 --control-listen-port 8084 &
snapd --tribe -t ${SNAP_TRUST_LEVEL} -l ${SNAP_LOG_LEVEL} --tribe-port 6003 --api-port 8184 --tribe-node-name node3 --tribe-seed 172.17.0.2:6000 --control-listen-port 8085 &
snapd --tribe -t ${SNAP_TRUST_LEVEL} -l ${SNAP_LOG_LEVEL} --tribe-port 6004 --api-port 8185 --tribe-node-name node4 --tribe-seed 172.17.0.2:6000 --control-listen-port 8086 &
snapd --tribe -t ${SNAP_TRUST_LEVEL} -l ${SNAP_LOG_LEVEL} --tribe-port 6005 --api-port 8186 --tribe-node-name node5 --tribe-seed 172.17.0.2:6000 --control-listen-port 8087 &
snapctl agreement create all-nodes
snapctl agreement join all-nodes node0
snapctl agreement join all-nodes node1
snapctl agreement join all-nodes node2
snapctl agreement join all-nodes node3
snapctl agreement join all-nodes node4
snapctl agreement join all-nodes node5
_info `netstat -natp | wc -l`
_info "Get latest plugins"
(cd $PLUGIN_PATH && curl -sfLSO http://snap.ci.snap-telemetry.io/plugins/snap-plugin-publisher-file/master/latest/linux/x86_64/snap-plugin-publisher-file && chmod 755 snap-plugin-publisher-file)
(cd $PLUGIN_PATH && curl -sfLSO http://snap.ci.snap-telemetry.io/plugins/snap-plugin-collector-docker/latest_build/linux/x86_64/snap-plugin-collector-docker && chmod 755 snap-plugin-collector-docker)
(cd $PLUGIN_PATH && curl -sfLSO http://snap.ci.snap-telemetry.io/snap/master/latest/snap-plugin-collector-mock1 && chmod 755 snap-plugin-collector-mock1)

SNAP_FLAG=0

# this block will wait check if snapctl and snapd are loaded before the plugins are loaded and the task is started
 for i in `seq 1 5`; do
             if [[ -f /usr/local/bin/snapctl && -f /usr/local/bin/snapd ]];
                then

                    _info "loading plugins"
                    snapctl plugin load "${PLUGIN_PATH}/snap-plugin-publisher-file"
                    _info `netstat -natp | wc -l`
                    snapctl plugin load "${PLUGIN_PATH}/snap-plugin-collector-mock1"
                    _info `netstat -natp | wc -l`
                    # bash
                    _info "creating and starting a task"
                    snapctl task create -t "${__dir}/docker-file.json"

                    SNAP_FLAG=1

                    break
             fi 
        
        _info "snapctl and/or snapd are unavailable, sleeping for 3 seconds" 
        sleep 3
done 


# check if snapctl/snapd have loaded
if [ $SNAP_FLAG -eq 0 ]
    then
     echo "Could not load snapctl or snapd"
     exit 1
fi
_info `netstat -natp | wc -l`
bash
pkill snapd