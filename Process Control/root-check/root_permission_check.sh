#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	echo "Please execute this script with sudo"
	exit 1
fi

echo "Running as root, continuing..."
