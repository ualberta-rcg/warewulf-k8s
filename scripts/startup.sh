#!/bin/bash

if [ -d "/build" ]; then

	cp -a /build/ww/* /

	cp -a /build/overlays/* ${OVERLAYDIR}/

	mkdir /container
	cp /build/scripts/* /container
	cp -f /build/scripts/service /usr/sbin/service
	mkdir -p /usr/share/bash_completion/completions/
	cp /etc/warewulf/bash_completion.d/* /usr/share/bash_completion/completions/
	
	rm -rf /build
fi

WWCONF=/etc/warewulf/warewulf.conf

yq e '.ipaddr = "EMPTY"' -i $WWCONF
yq e ".netmask = \"${NETMASK:=EMPTY}\"" -i $WWCONF
yq e ".network = \"${NETWORK:=EMPTY}\"" -i $WWCONF
yq e '.nfs.enabled = "false"' -i $WWCONF

OVERLAYDIR=`yq '.paths.wwoverlaydir' $WWCONF`

useradd -r -d /nonexistent -s /usr/sbin/nologin munge
useradd -r -d /nonexistent -s /usr/sbin/nologin slurm

chown munge:munge ${OVERLAYDIR}/slurm/rootfs/etc/munge/munge.key.ww
mkdir -p ${OVERLAYDIR}/cvmfs/rootfs/usr/local/bin
cd ${OVERLAYDIR}/cvmfs/rootfs/usr/local/bin/
curl -O https://cvmrepo.s3.cern.ch/cvmrepo/apt/cvmfs-release-latest_all.deb

/container/start
