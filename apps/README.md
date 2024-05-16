# apps

## bind

<https://www.isc.org/bind/>

### bind configuration

> [!IMPORTANT]
> _**Do not** modify the key contents after it's creation, instead create a new key using `tsig-keygen`._

1. Create the base rndc key and encrypt it with sops

    ```sh
    tsig-keygen -a hmac-sha256 rndc-key > ./apps/bind/data/config/rndc.sops.key
    sops --encrypt --in-place ./apps/bind/data/config/rndc.sops.key
    ```

2. [Optional] Create additional rndc keys for external-dns and encrypt them with sops

3. Update `./apps/bind/data/config` with your configuration and then start it

    ```sh
    task start-bind
    ```

## blocky

<https://github.com/0xERR0R/blocky>

### blocky configuration

> [!IMPORTANT]
> _Blocky can take awhile to start depending on how many blocklists you have configured_

1. Update `./apps/blocky/data/config/config.yaml` with your configuration and then start it

    ```sh
    task start-blocky
    ```

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
