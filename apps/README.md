# apps

## bind

https://www.isc.org/bind/

### Configuration

> [!IMPORTANT]
> _**Do not** modify the key contents after it's creation, instead create a new key using `tsig-keygen`._

1. Create the base rndc key and encrypt it with sops

    ```sh
    tsig-keygen -a hmac-sha256 rndc-key > ./apps/bind/data/config/rndc.sops.key
    sops --encrypt --in-place ./apps/bind/data/config/rndc.sops.key
    ```

2. Update `./apps/bind/data/config` with your configuration and then start it

    ```sh
    task start-bind
    ```

## Optional configuration

1. Create additional rndc keys for external-dns and encrypt them with sops

    ```sh
    tsig-keygen -a hmac-sha256 kubernetes-main-key > ./apps/bind/data/config/kubernetes-main.sops.key
    sops --encrypt --in-place ./apps/bind/data/config/kubernetes-main.sops.key
    ```

## blocky

https://github.com/0xERR0R/blocky

### Configuration

> [!IMPORTANT]
> _Blocky can take awhile to start depending on how many blocklists you have configured_

1. Update `./apps/blocky/data/config/config.yaml` with your configuration and then start it

    ```sh
    task start-blocky
    ```

## dnsdist

https://dnsdist.org

### Configuration

1. Update `./apps/dnsdist/data/config/dnsdist.conf` with your configuration and then start it

    ```sh
    task start-dnsdist
    ```

## onepassword

https://github.com/1Password/connect

### Configuration

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

https://github.com/containers/prometheus-podman-exporter

### Configuration

1. Enable the `podman.socket` service

    ```sh
    sudo systemctl enable --now podman.socket
    ```

2. Start `podman-exporter`

    ```sh
    task start-podman-exporter
    ```
