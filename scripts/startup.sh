#!/bin/bash

if [ -d "/build" ]; then
	cp -a --update=none /build/ww/* /
fi

WWCONF=/etc/warewulf/warewulf.conf

if [ -d "/build" ]; then
	if [ -d "/build/overlays" ]; then
		OVERLAYDIR=`yq '.paths.wwoverlaydir' $WWCONF | tr -d '"'`
		mkdir -p ${OVERLAYDIR}
		cp -a /build/overlays/* ${OVERLAYDIR}/
		ln -s /etc/systemd/system/ansible-run.service ${OVERLAYDIR}/ansible/rootfs/etc/systemd/system/multi-user.target.wants/ansible-run.service
		if [ ! -f "${OVERLAYDIR}/cvmfs/rootfs/usr/local/bin/cvmfs-release-latest_all.deb" ]; then
			mkdir -p ${OVERLAYDIR}/cvmfs/rootfs/usr/local/bin
			cd ${OVERLAYDIR}/cvmfs/rootfs/usr/local/bin/
			curl -O https://cvmrepo.s3.cern.ch/cvmrepo/apt/cvmfs-release-latest_all.deb
		fi
	fi
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
yq -yi '.tftp.tftproot = "/host/ipxe"' $WWCONF

/container/start
