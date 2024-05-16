#!/usr/bin/env bash

echo "blocky external query"
dig +short @192.168.1.121 google.com | sed 's/^/  /'
echo "bind external query"
dig +short @192.168.1.123 google.com | sed 's/^/  /'
echo "-----------------------------"
echo "blocky internal query"
dig +short @192.168.1.121 expanse.turbo.ac | sed 's/^/  /'
echo "bind internal query"
dig +short @192.168.1.123 expanse.turbo.ac | sed 's/^/  /'
echo "-----------------------------"
echo "blocky cluster query"
dig +short @192.168.1.121 echo-server.devbu.io | sed 's/^/  /'
echo "bind cluster query"
dig +short @192.168.1.123 echo-server.devbu.io | sed 's/^/  /'
echo "-----------------------------"
