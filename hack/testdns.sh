#!/usr/bin/env bash

echo "BLOCKY external query"
dig +short @192.168.1.121 google.com | sed 's/^/  /'
echo "---"
echo "BLOCKY internal UNIFI device query"
dig +short @192.168.1.121 unifi.internal | sed 's/^/  /'
echo "BLOCKY internal UNIFI custom query"
dig +short @192.168.1.121 unifi.turbo.ac | sed 's/^/  /'
echo "---"
echo "BLOCKY main cluster query"
dig +short @192.168.1.121 echo-server.devbu.io | sed 's/^/  /'
echo "BLOCKY main cluster query"
dig +short @192.168.1.121 echo-server.devbu.io | sed 's/^/  /'
echo "BLOCKY storage cluster query"
dig +short @192.168.1.121 echo-server.turbo.ac | sed 's/^/  /'
echo "---"
echo "BLOCKY reverse query"
dig +short @192.168.1.121 -x 192.168.42.80 | sed 's/^/  /'
echo "---------------------------------------------------"
