#!/usr/bin/env bash

for file in apps/*/*.container; do
    ip=$(grep -oP '(?<=IP=).*' "$file")
    if [ -n "$ip" ]; then
        echo "Container Name: $(basename ${file%%.*})"
        echo "IP: $ip"
        echo "-----------------------------"
    fi
done
