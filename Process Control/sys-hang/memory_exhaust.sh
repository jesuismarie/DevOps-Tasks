#!/bin/bash

memory=()

while true; do
	memory+=( $(dd if=/dev/urandom bs=1M count=1 2>/dev/null | base64) )
done
