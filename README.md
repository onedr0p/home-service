# home-service

My home service stack running on a [Beelink EQ12](https://www.bee-link.com/eq12-n100-clone-1) with [Fedora IoT](https://fedoraproject.org/iot/). These [podman](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html) services are supporting my home infrastructure including, DNS and Kubernetes clusters.

## Core Components

- [1password-connect](https://github.com/1Password/connect): API server for 1Password that lets me integrate secrets into my infrastructure and Kubernetes clusters.
- [bind9](https://www.isc.org/bind/): Authoritative DNS server for my domains.
- [blocky](https://github.com/0xERR0R/blocky): Fast and lightweight ad-blocker.
- [dnsdist](https://dnsdist.org/): A DNS load balancer.
- [matchbox](https://github.com/poseidon/matchbox): PXE boot bare-metal machines.
- [node-exporter](https://github.com/prometheus/node_exporter): Exporter for machine metrics.
- [podman-exporter](https://github.com/containers/prometheus-podman-exporter): Prometheus exporter for podman.
- [sops](https://github.com/getsops/sops): Manage secrets which are commited to Git.
- [tftpd](https://linux.die.net/man/8/tftpd): A trivial file transfer protocol server for use with PXE.
- [traefik](https://github.com/traefik/traefik): Reverse proxy for L7 applications.

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

## Network configuration

> [!NOTE]
> _I am using [ipvlan](https://docs.docker.com/network/drivers/ipvlan) to expose containers on their own IP addresses on the same network as this here device, the available addresses are mentioned in the `--ip-range` flag below. **Beware** of **IP addressing** and **interface names**._

1. Create the podman `containernet` network

    ```sh
    sudo podman network create \
        --driver=ipvlan \
        --ipam-driver=host-local \
        --subnet=192.168.1.0/24 \
        --gateway=192.168.1.1 \
        --ip-range=192.168.1.101-192.168.1.120 \
        containernet
    ```

2. Setup the currently used interface with `systemd-networkd`

    ```sh
    sudo bash -c 'cat << EOF > /etc/systemd/network/enp1s0.network
    [Match]
    Name = enp1s0
    [Network]
    DHCP = yes
    IPVLAN = containernet'
    ```

3. Setup `containernet` with `systemd-networkd`

    ```sh
    sudo bash -c 'cat << EOF > /etc/systemd/network/containernet.netdev
    [NetDev]
    Name = containernet
    Kind = ipvlan'
    sudo bash -c 'cat << EOF > /etc/systemd/network/containernet.network
    [Match]
    Name = containernet
    [Network]
    IPForward = yes
    Address = 192.168.1.100/24'
    ```

5. Disable `networkmanager`, the enable and start `systemd-networkd`

    ```sh
    sudo systemctl disable --now networkmanager
    sudo systemctl enable --now systemd-networkd
    ```

## Container configuration

### bind

> [!IMPORTANT]
> _**Do not** modify the key contents after it's creation, instead create a new key using `tsig-keygen`._

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
> _Blocky can take awhile to start depending on how many blocklists you have configured_

1. Update `./containers/blocky/data/config/config.yaml` with your configuration and then start it

    ```sh
    task start-blocky
    ```

### dnsdist

> [!IMPORTANT]
> _Prevent `systemd-resolved` from listening on port `53`_
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
> _This is for only using the [fish shell](https://fishshell.com/)_

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
sudo systemctl disable --now firewalld.service
```

## Related Projects

- [bjw-s/nix-config](https://github.com/bjw-s/nix-config/): NixOS driven configuration for running a home service machine, a nas or [nix-darwin](https://github.com/LnL7/nix-darwin) using [deploy-rs](https://github.com/serokell/deploy-rs) and [home-manager](https://github.com/nix-community/home-manager).
