#!/usr/bin/env bash

sudo mkdir /etc/containers/systemd/
sudo rm -rf /etc/containers/systemd/*
sudo cp -r /home/devin/Code/home-dns/etc/containers/systemd /etc/containers

sudo systemctl daemon-reload

sudo systemctl stop bind
sudo systemctl stop blocky
sudo systemctl stop dnsdist
sudo systemctl start bind
sudo systemctl start blocky
sudo systemctl start dnsdist

sleep 5
sudo podman ps
