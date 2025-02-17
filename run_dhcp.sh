#!/bin/sh

while true; do
	/usr/sbin/dnsmasq --no-daemon --keep-in-foreground --log-queries --log-facility=- &
	PID=$!
	if [ ! -d "/proc/$PID"]; then
		continue
	fi
	inotifywait -e modify -e create -e delete -e move -r /etc/dnsmasq.d
	kill -9 $PID
done
