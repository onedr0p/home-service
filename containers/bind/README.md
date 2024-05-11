# bind

https://www.isc.org/bind/

## Configuration

> [!IMPORTANT]
> _**Do not** modify the key contents after it's creation, instead create a new key using `tsig-keygen`._

1. Create the base rndc key and encrypt it with sops

    ```sh
    tsig-keygen -a hmac-sha256 rndc-key > ./containers/bind/data/config/rndc.sops.key
    sops --encrypt --in-place ./containers/bind/data/config/rndc.sops.key
    ```

2. Update `./containers/bind/data/config` with your configuration and then start it

    ```sh
    task start-bind
    ```

## Optional configuration

1. Create additional rndc keys for external-dns and encrypt them with sops

    ```sh
    tsig-keygen -a hmac-sha256 kubernetes-main-key > ./containers/bind/data/config/kubernetes-main.sops.key
    sops --encrypt --in-place ./containers/bind/data/config/kubernetes-main.sops.key
    ```
