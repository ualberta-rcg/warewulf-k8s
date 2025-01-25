#!/bin/bash
cd /etc/ansible
for p in `ls -1 | sort`; do
	/root/.local/bin/ansible-playbook ${p}
done
