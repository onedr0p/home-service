# home-dns

My home DNS stack running on [Fedora IoT](https://fedoraproject.org/iot/) and managed by podman and systemd.

## System configuration

1. Install base system deps and reboot ...

    ```sh
    sudo rpm-ostree install --idempotent --assumeyes git go-task
    sudo systemctl reboot
    ```

2. Make a new [SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent), add it to GitHub and clone your repo ...

    ```sh
    export GITHUB_USER="onedr0p"
    curl https://github.com/$GITHUB_USER.keys > ~/.ssh/authorized_keys
    sudo mkdir -p /var/opt/home-dns
    sudo chown -R $(logname):$(logname) /var/opt/home-dns
    cd /var/opt/home-dns
    git clone git@github.com:$GITHUB_USER/home-dns.git .
    ```

3. Install additional system deps ...

    ```sh
    cd /var/opt/home-dns
    go-task deps
    ```

4. Set `selinux` to `permissive` ...

    ```sh
    sudo sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
    ```

5. Disable `firewalld` ...

    ```sh
    sudo systemctl mask firewalld.service
    ```

6. Ensure `systemd-resolved` is not listening on port `53` ...

    ```sh
    sudo bash -c 'cat << EOF > /etc/systemd/resolved.conf.d/stub-listener.conf
    [Resolve]
    DNSStubListener=no'
    ```

7. Reboot `sudo systemctl reboot` ...

## Container configuration

### bind

> [!IMPORTANT]
> **Do not** modify the key contents after it's creation, instead create a new key using `tsig-keygen`.

1. Create the base rndc key ...

    ```sh
    tsig-keygen -a hmac-sha256 rndc-key > ./containers/bind/data/config/rndc.key
    ```

2. Create additional rndc keys for external-dns ...

    ```sh
    tsig-keygen -a hmac-sha256 kubernetes-main-key > ./containers/bind/data/config/kubernetes-main.key
    ```

3. Edit `./containers/bind/data/config/named.conf` with your included keys and zones ...

4. Update `./containers/bind/data/config/zones` with your DNS configuration ...

5. Start bind ...

    ```sh
    go-task start-bind
    ```

### blocky

> [!IMPORTANT]
> Blocky can take awhile to start depending on how many blocklists you have configured

1. Edit `./containers/blocky/data/config/config.yaml` with your bind IP address for `.clientLookup.upstream` ...

2. Change any other configuration you want (e.g. blocklists) ...

3. Start blocky ...

    ```sh
    go-task start-blocky
    ```

### dnsdist

1. Edit `./containers/dnsdist/data/config/dnsdist.conf` and update the IP addresses for bind and blocky ...

2. Change the actions to suit your networks ...

3. Start dnsdist ...

    ```sh
    go-task start-dnsdist
    ```

### onepassword

1. Add your `./containers/onepassword-connect/data/config/1password-credentials.json` ...

2. Start `onepassword-connect` and `onepassword-sync` ...

    ```sh
    go-task start-onepassword-connect
    go-task start-onepassword-sync
    ```

### podman-exporter

1. Start the `podman.socket` service is running ...

    ```sh
    sudo systemctl enable --now podman.socket
    ```

2. Start podman-exporter ...

    ```sh
    go-task start-podman-exporter
    ```

### node-exporter

1. Start node-exporter ...

    ```sh
    go-task start-node-exporter
    ```

## Testing DNS

```sh
dig +short @192.168.1.42 -p 53 google.com         # dnsdist external query
dig +short @192.168.1.42 -p 53 expanse.turbo.ac   # dnsdist internal query
dig +short @192.168.1.42 -p 5300 google.com       # bind external query
dig +short @192.168.1.42 -p 5300 expanse.turbo.ac # bind internal query
dig +short @192.168.1.42 -p 5301 google.com       # blocky external query
dig +short @192.168.1.42 -p 5301 expanse.turbo.ac # blocky internal query
```
