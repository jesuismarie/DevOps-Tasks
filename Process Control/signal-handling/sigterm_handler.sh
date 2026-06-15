#!/bin/bash

trap "echo \"You can't terminate me\"" SIGTERM

echo "Process started with PID: $$"

while true; do
	sleep 1
done
