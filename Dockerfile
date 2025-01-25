FROM ubuntu:24.04 as builder

RUN apt update -y && apt upgrade -y && \
	DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
	git \
	golang \
	unzip \
	ca-certificates \
	build-essential \
	curl
	
RUN mkdir /src && \
	cd /src && \
	git clone https://github.com/warewulf/warewulf.git && \
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
	make && \
	make install

FROM ubuntu:24.04

RUN mkdir -p /build/ww/usr/bin /build/ww/usr/bin /build/ww/var/lib /build/ww/usr/share /build/ww/etc

COPY --from=builder /usr/bin/wwctl /build/ww/usr/bin/wwctl
COPY --from=builder /var/lib/warewulf /build/ww/var/lib/warewulf
COPY --from=builder /usr/share/warewulf /build/ww/usr/share/warewulf
COPY --from=builder /etc/warewulf /build/ww/etc/warewulf

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
	gawk && \
	apt clean

COPY . /build

ENTRYPOINT [ "/build/scripts/startup.sh" ]

EXPOSE 9873
