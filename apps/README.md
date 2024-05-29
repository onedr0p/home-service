# apps

## dhcp-proxy

<https://github.com/poseidon/dnsmasq>

## gatus

<https://github.com/TwiN/gatus>

## matchbox

<https://github.com/poseidon/matchbox>

## node-exporter

<https://github.com/prometheus/node_exporter>

## op-connect

<https://github.com/1Password/connect>

### op-connect configuration

1. Add your `./apps/op-connect-api/data/config/1password-credentials.sops.json` configuration and encrypted it with sops

    ```sh
    sops --encrypt --in-place ./apps/op-connect-api/data/config/1password-credentials.sops.json
    ```

2. Start `op-connect-api` and `op-connect-sync`

    ```sh
    task start-op-connect-api
    task start-op-connect-sync
    ```

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

## smtp-relay

<https://github.com/foxcpp/maddy>

## traefik

<https://github.com/traefik/traefik>
