# home-dns

## bind

> [!IMPORTANT]
> **Do not** modify the key contents after it's created, instead create a new key using `tsig-keygen`.

1. Create the base rndc key...

    ```sh
    tsig-keygen -a hmac-sha256 rndc-key > ./bind/config/rndc.key
    ```

2. Create additional rndc keys for external-dns...

    ```sh
    tsig-keygen -a hmac-sha256 kubernetes-main-key > ./bind/config/kubernetes-main.key
    ```

1. Edit `./bind/config/named.conf` with your trusted VLANs, included keys and zones.
2. Update `./bind/config/zones` with your DNS configuration.

## blocky

1. Edit `./blocky/config/config.yaml` with your bind IP address.
2. Change any other configuration you want (e.g. blocklists)

## dnsdist

1. Edit `./dnsdist/config/dnsdist.conf` and update the IP addresses for bind and blocky.
2. Change the actions to suit your needs.
