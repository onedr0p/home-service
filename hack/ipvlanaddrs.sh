#!/usr/bin/env bash

for file in containers/*/*.container; do
    ip=$(grep -oP '(?<=IP=).*' "$file")
    if [ -n "$ip" ]; then
        echo "Container Name: $container_name"
        echo "IP: $ip"
        echo "-----------------------------"
    fi
done
