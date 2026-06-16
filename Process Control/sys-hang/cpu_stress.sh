#!/bin/bash

echo "Starting CPU stress test..."

CORES=$(nproc)

for i in $(seq 1 $CORES); do
	yes > /dev/null &
done

echo "Started $CORES CPU workers."
wait
