#!/bin/bash

cp -a /build/ww/* /

WWCONF=/etc/warewulf/warewulf.conf

yq e '.ipaddr = "EMPTY"' -i $WWCONF
yq e ".netmask = \"${NETMASK:=EMPTY}\"" -i $WWCONF
yq e ".network = \"${NETWORK:=EMPTY}\"" -i $WWCONF
yq e '.nfs.enabled = "false"' -i $WWCONF

OVERLAYDIR=`yq '.paths.wwoverlaydir' $WWCONF`

cp -a /build/overlays/* $OVERLAYDIR/
echo 'munge:x:114:118::/nonexistent:/usr/sbin/nologin' >> /etc/passwd
chown munge:munge $OVERLAYDIR/slurm/rootfs/etc/munge/munge.key.ww

mkdir /container
cp /build/scripts/* /container
cp -f /build/scripts/service /usr/sbin/service
mkdir -p /usr/share/bash_completion/completions/
cp /etc/warewulf/bash_completion.d/* /usr/share/bash_completion/completions/

rm -rf /build

/container/start
