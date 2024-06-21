# apps

## dhcp-proxy

<https://github.com/poseidon/dnsmasq>

## matchbox

<https://github.com/poseidon/matchbox>

## node-exporter

<https://github.com/prometheus/node_exporter>

## podman-exporter

<https://github.com/containers/prometheus-podman-exporter>

### podman-exporter configuration

1. Enable the `podman.socket` service

    ```sh
    sudo systemctl enable --now podman.socket
    ```

2. Start `podman-exporter`

    ```sh
    task start-podman-exporter
    ```
