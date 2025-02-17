#!/bin/bash

cd /build/patches
for fn in `ls -1 *.patch`; do
	patch -d/ -p0 < ${fn}
done
