#!/bin/sh
PID=0
while true; do
	if [ ! -d "/proc/$PID" ]; then
		/usr/sbin/dnsmasq --no-daemon --keep-in-foreground --log-queries --log-facility=- &
		PID=$!
	fi
	inotifywait -e modify -e create -e delete -e move -t 10 -r /etc/dnsmasq.d
	if [ $? -eq 0 ]; then
		echo "Restarting dnsmasq"
		kill -9 $PID
	fi
done
