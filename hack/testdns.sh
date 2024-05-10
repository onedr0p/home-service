#!/usr/bin/env bash

echo "dnsdist external query"
dig +short @192.168.1.42 google.com | sed 's/^/  /'
echo "bind external query"
dig +short @192.168.1.123 google.com | sed 's/^/  /'
echo "blocky external query"
dig +short @192.168.1.122 google.com | sed 's/^/  /'
echo "-----------------------------"
echo "dnsdist internal query"
dig +short @192.168.1.42 expanse.turbo.ac | sed 's/^/  /'
echo "bind internal query"
dig +short @192.168.1.123 expanse.turbo.ac | sed 's/^/  /'
echo "blocky internal query"
dig +short @192.168.1.122 expanse.turbo.ac | sed 's/^/  /'
echo "-----------------------------"
echo "dnsdist cluster query"
dig +short @192.168.1.42 echo-server.devbu.io | sed 's/^/  /'
echo "bind cluster query"
dig +short @192.168.1.123 echo-server.devbu.io | sed 's/^/  /'
echo "blocky cluster query"
dig +short @192.168.1.122 echo-server.devbu.io | sed 's/^/  /'
echo "-----------------------------"
