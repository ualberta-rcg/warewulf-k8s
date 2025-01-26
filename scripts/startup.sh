#!/bin/bash

if [ -d "/build" ]; then
	cp -a /build/ww/* /
fi

WWCONF=/etc/warewulf/warewulf.conf
OVERLAYDIR=`yq '.paths.wwoverlaydir' $WWCONF | tr -d '"'`

if [ -d "/build" ]; then
	mkdir -p ${OVERLAYDIR}
	cp -a /build/overlays/* ${OVERLAYDIR}/
	ln -s /etc/systemd/system/ansible-run.service ${OVERLAYDIR}/ansible/rootfs/etc/systemd/system/multi-user.target.wants/ansible-run.service

	mkdir /container
	cp /build/scripts/* /container
	cp -f /build/scripts/service /usr/sbin/service
	mkdir -p /usr/share/bash_completion/completions/
	cp /etc/warewulf/bash_completion.d/* /usr/share/bash_completion/completions/
fi

if [ `find /host/ipxe -iname '*.efi' | wc -l` -eq 0 ]; then
	cp -a /build/ipxe/warewulf /host/ipxe/
fi

yq -yi '.ipaddr = "EMPTY"' $WWCONF
yq -yi ".netmask = \"${NETMASK}\"" $WWCONF
yq -yi ".network = \"${NETWORK}\"" $WWCONF
yq -yi '.nfs.enabled = false' $WWCONF
yq -yi '.dhcp.enabled = false' $WWCONF
yq -yi '.tftp.enabled = false' $WWCONF
yq -yi '.tftp.tftproot = "/host/ipxe"' $WWCONF

useradd -r -d /nonexistent -s /usr/sbin/nologin munge
useradd -r -d /nonexistent -s /usr/sbin/nologin slurm

chown munge:munge ${OVERLAYDIR}/slurm/rootfs/etc/munge/munge.key.ww
mkdir -p ${OVERLAYDIR}/cvmfs/rootfs/usr/local/bin
cd ${OVERLAYDIR}/cvmfs/rootfs/usr/local/bin/
curl -O https://cvmrepo.s3.cern.ch/cvmrepo/apt/cvmfs-release-latest_all.deb

/container/start
