# Adapted from the official warewulf Dockerfile
FROM ubuntu:24.04 as builder

ARG WW_VER
ENV WW_VER="v4.6.2"

RUN apt update -y && apt upgrade -y && \
	DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
	git \
	golang \
	unzip \
	ca-certificates \
	build-essential \
	curl \
	liblzma-dev

RUN mkdir /build

COPY . /build

RUN mkdir /src && \
	cd /src && \
	git clone https://github.com/warewulf/warewulf.git --branch "${WW_VER}" --depth 1 && \
	cd warewulf && \
	make clean OFFLINE_BUILD=1 && \
	make defaults \
		PREFIX=/usr \
		BINDIR=/usr/bin \
		SYSCONFDIR=/etc \
		DATADIR=/usr/share \
		LOCALSTATEDIR=/var/lib \
		MANDIR=/usr/share/man \
		INFODIR=/usr/share/info \
		DOCDIR=/usr/share/doc \
		SRVDIR=/var/lib \
		TFTPDIR=/src/tftpboot \
		SYSTEMDDIR=/usr/lib/systemd/system \
		BASHCOMPDIR=/etc/warewulf/bash_completion.d \
		FIREWALLDDIR=/usr/lib/firewalld/service \
		WWCLIENTDIR=/warewulf && \
	make lint && \
	make build && \
	make install && \
	( DESTDIR=/src /src/warewulf/scripts/build-ipxe.sh )

RUN /build/scripts/patch_warewulf.sh

FROM ubuntu:24.04

RUN mkdir -p /build/ww/usr/bin /build/ww/usr/bin /build/ww/var/lib /build/ww/usr/share /build/ww/etc /build/ipxe/warewulf

COPY --from=builder /usr/bin/wwctl /build/ww/usr/bin/wwctl
COPY --from=builder /var/lib/warewulf /build/ww/var/lib/warewulf
COPY --from=builder /usr/share/warewulf /build/ww/usr/share/warewulf
COPY --from=builder /etc/warewulf /build/ww/etc/warewulf
COPY --from=builder /src/*.kpxe /build/ipxe/warewulf
COPY --from=builder /src/*.efi /build/ipxe/warewulf

RUN apt update -y && apt upgrade -y && apt install -y --no-install-recommends \
	cpio \
	gzip \
	pigz \
	rsync \
	openssh-client \
	less \
	iproute2 \
	vim \
	nano \
	yq \
	ca-certificates \
	curl \
        dnsmasq \
	gawk && \
	apt clean

COPY . /build

ENTRYPOINT [ "/build/scripts/startup.sh" ]

EXPOSE 9873
