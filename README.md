# home-service

My home service stack running on a [Beelink EQ12](https://www.bee-link.com/eq12-n100-clone-1) with [Fedora IoT](https://fedoraproject.org/iot/). These [podman](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html) services are supporting my home infrastructure including, DNS and Kubernetes clusters.

## Core Components

- [bind9](https://www.isc.org/bind/): Authoritative DNS server for my domains.
- [blocky](https://github.com/0xERR0R/blocky): Fast and lightweight ad-blocker.
- [dnsdist](https://dnsdist.org/): A DNS load balancer.
- [matchbox](https://github.com/poseidon/matchbox): PXE boot bare-metal machines.
- [node-exporter](https://github.com/prometheus/node_exporter): Exporter for machine metrics.
- [1password-connect](https://github.com/1Password/connect): Access 1Password secrets.
- [podman-exporter](https://github.com/containers/prometheus-podman-exporter): Prometheus exporter for podman.
- [tftpd](https://linux.die.net/man/8/tftpd): A trivial file transfer protocol server.

## System configuration

> [!IMPORTANT]
> A non-root user must be created (if not already) and used.

1. Install required system deps and reboot

    ```sh
    sudo rpm-ostree install --idempotent --assumeyes git go-task
    sudo systemctl reboot
    ```

2. Make a new [SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent), add it to GitHub and clone your repo

    ```sh
    export GITHUB_USER="onedr0p"
    curl https://github.com/$GITHUB_USER.keys > ~/.ssh/authorized_keys
    sudo mkdir -p /var/opt/home-service
    sudo chown -R $(logname):$(logname) /var/opt/home-service
    cd /var/opt/home-service
    git clone git@github.com:$GITHUB_USER/home-service.git .
    ```

3. Install additional system deps and reboot

    ```sh
    task deps
    sudo systemctl reboot
    ```

## Container configuration

### bind

> [!IMPORTANT]
> **Do not** modify the key contents after it's creation, instead create a new key using `tsig-keygen`.

1. Create the base rndc key

    ```sh
    tsig-keygen -a hmac-sha256 rndc-key > ./containers/bind/data/config/rndc.key
    ```

2. Create additional rndc keys for external-dns

    ```sh
    tsig-keygen -a hmac-sha256 kubernetes-main-key > ./containers/bind/data/config/kubernetes-main.key
    ```

3. Update `./containers/bind/data/config` with your configuration and then start it

    ```sh
    task start-bind
    ```

### blocky

> [!IMPORTANT]
> Blocky can take awhile to start depending on how many blocklists you have configured

1. Update `./containers/blocky/data/config/config.yaml` with your configuration and then start it

    ```sh
    task start-blocky
    ```

### dnsdist

> [!IMPORTANT]
> Prevent `systemd-resolved` from listening on port `53`
> ```sh
> sudo bash -c 'cat << EOF > /etc/systemd/resolved.conf.d/stub-listener.conf
> [Resolve]
> DNSStubListener=no'
> sudo systemctl restart systemd-resolved
> ```

1. Update `./containers/dnsdist/data/config/dnsdist.conf` with your configuration and then start it

    ```sh
    task start-dnsdist
    ```

### onepassword

1. Add your `./containers/op-connect-api/data/config/1password-credentials.json` configuration

2. Start `op-connect-api` and `op-connect-sync`

    ```sh
    task start-op-connect-api
    task start-op-connect-sync
    ```

### node-exporter

1. Start `node-exporter`

    ```sh
    task start-node-exporter
    ```

### podman-exporter

1. Enable the `podman.socket` service

    ```sh
    sudo systemctl enable --now podman.socket
    ```

2. Start `podman-exporter`

    ```sh
    task start-podman-exporter
    ```

### tftpd

1. Download the required tftpd / PXE files

    ```sh
    task tftpd:deps
    ```

2. Start `tftpd`

    ```sh
    task start-tftpd
    ```

## Testing DNS

```sh
echo "dnsdist external query"; dig +short @192.168.1.42 -p 53 google.com | sed 's/^/  /'
echo "dnsdist internal query"; dig +short @192.168.1.42 -p 53 expanse.turbo.ac | sed 's/^/  /'
echo "bind external query";    dig +short @192.168.1.42 -p 5300 google.com | sed 's/^/  /'
echo "bind internal query";    dig +short @192.168.1.42 -p 5300 expanse.turbo.ac | sed 's/^/  /'
echo "blocky external query";  dig +short @192.168.1.42 -p 5301 google.com | sed 's/^/  /'
echo "blocky internal query";  dig +short @192.168.1.42 -p 5301 expanse.turbo.ac | sed 's/^/  /'
```

## Optional configuration

### Alias go-task

> [!NOTE]
> This is for only using the [fish shell](https://fishshell.com/)

```sh
function task --wraps=go-task --description 'go-task shorthand'
    go-task $argv
end
funcsave task
```

### Tune selinux

```sh
sudo sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
```

### Disable firewalld

```sh
sudo systemctl mask firewalld.service
```
