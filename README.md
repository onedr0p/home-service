# home-dns

## Prepare Debian

```sh
sudo apt install curl gpg gnupg2 software-properties-common apt-transport-https lsb-release ca-certificates

source /etc/os-release

wget http://downloadcontent.opensuse.org/repositories/home:/alvistack/Debian_$VERSION_ID/Release.key -O alvistack_key

echo "deb http://downloadcontent.opensuse.org/repositories/home:/alvistack/Debian_$VERSION_ID/ /" | sudo tee /etc/apt/sources.list.d/alvistack.list

cat alvistack_key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/alvistack.gpg >/dev/null

sudo apt update

sudo apt install podman python3-podman-compose uidmap slirp4netns netavark
```

## Apps

### bind

> [!IMPORTANT]
> **Do not** modify the key contents after it's creation, instead create a new key using `tsig-keygen`.

1. Create the base rndc key...

    ```sh
    tsig-keygen -a hmac-sha256 rndc-key > ./etc/containers/systemd/bind/config/rndc.key
    ```

2. Create additional rndc keys for external-dns...

    ```sh
    tsig-keygen -a hmac-sha256 kubernetes-main-key > ./etc/containers/systemd/bind/config/kubernetes-main.key
    ```

3. Edit `./etc/containers/systemd/bind/config/named.conf` with your included keys and zones.
4. Update `./etc/containers/systemd/bind/config/zones` with your DNS configuration.

### blocky

> [!IMPORTANT]
> Blocky can take awhile to start depending on how many blocklists you have configured

1. Edit `./etc/containers/systemd/blocky/config/config.yaml` with your bind IP address for `.clientLookup.upstream`
2. Change any other configuration you want (e.g. blocklists)

### dnsdist

1. Edit `./etc/containers/systemd/dnsdist/config/dnsdist.conf` and update the IP addresses for bind and blocky.
2. Change the actions to suit your networks.

## Testing

```sh
dig @192.168.1.50 -p 53 google.com         # dnsdist external query
dig @192.168.1.50 -p 53 expanse.turbo.ac   # dnsdist internal query
dig @192.168.1.50 -p 5301 google.com       # blocky external query
dig @192.168.1.50 -p 5301 expanse.turbo.ac # blocky internal query
dig @192.168.1.50 -p 5300 google.com       # bind external query
dig @192.168.1.50 -p 5300 expanse.turbo.ac # bind internal query
```
