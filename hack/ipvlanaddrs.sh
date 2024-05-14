#!/usr/bin/env bash

declare -A container_ips

for file in apps/*/*.container; do
    ip=$(grep -oP '(?<=IP=).*' "$file")
    if [ -n "$ip" ]; then
        container_name=$(basename "${file%%.*}")
        container_ips["$container_name"]=$ip
    fi
done

# Sort the container names by IP address
sorted_container_names=($(for ip in "${container_ips[@]}"; do echo "$ip"; done | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4))

# Print the sorted results
for ip in "${sorted_container_names[@]}"; do
    for container_name in "${!container_ips[@]}"; do
        if [[ "${container_ips[$container_name]}" == "$ip" ]]; then
            echo "Container Name: $container_name"
            echo "IP: $ip"
            echo "-----------------------------"
        fi
    done
done
