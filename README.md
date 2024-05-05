# home-dns

## Apps

### bind

> [!IMPORTANT]
> **Do not** modify the key contents after it's creation, instead create a new key using `tsig-keygen`.

1. Create the base rndc key...

    ```sh
    tsig-keygen -a hmac-sha256 rndc-key > ./bind9/config/rndc.key
    ```

2. Create additional rndc keys for external-dns...

    ```sh
    tsig-keygen -a hmac-sha256 kubernetes-main-key > ./bind9/config/kubernetes-main.key
    ```

3. Edit `./bind9/config/named.conf` with your included keys and zones.
4. Update `./bind9/config/zones` with your DNS configuration.

### blocky

> [!IMPORTANT]
> Blocky can take awhile to start depending on how many blocklists you have configured

1. Edit `./blocky/config/config.yaml` with your bind IP address for `.clientLookup.upstream`
2. Change any other configuration you want (e.g. blocklists)

### dnsdist

1. Edit `./dnsdist/config/dnsdist.conf` and update the IP addresses for bind and blocky.
2. Change the actions to suit your needs.

## Testing

```sh
dig @192.168.10.214 -p 53 google.com          # dnsdist external query
dig @192.168.10.214 -p 53 expanse.turbo.ac    # dnsdist internal query
dig @192.168.10.214 -p 53003 google.com       # blocky external query
dig @192.168.10.214 -p 53003 expanse.turbo.ac # blocky internal query
dig @192.168.10.214 -p 53002 google.com       # bind external query
dig @192.168.10.214 -p 53002 expanse.turbo.ac # bind internal query
```
