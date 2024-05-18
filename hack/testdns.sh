#!/usr/bin/env bash

echo "BLOCKY external query"
dig +short @192.168.1.121 google.com | sed 's/^/  /'
echo "---"
echo "BLOCKY internal query"
dig +short @192.168.1.121 unifi.internal | sed 's/^/  /'
echo "BLOCKY internal BIND query"
dig +short @192.168.1.121 unifi.turbo.ac | sed 's/^/  /'
echo "---"
echo "BLOCKY main cluster query"
dig +short @192.168.1.121 echo-server.devbu.io | sed 's/^/  /'
echo "BIND main cluster query"
dig +short @192.168.1.123 echo-server.devbu.io | sed 's/^/  /'
echo "BIND storage cluster query"
dig +short @192.168.1.123 s3.turbo.ac | sed 's/^/  /'
echo "---"
echo "BLOCKY reverse query"
dig +short @192.168.1.121 -x 192.168.42.80 | sed 's/^/  /'
echo "---------------------------------------------------"
