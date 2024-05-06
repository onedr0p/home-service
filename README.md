# home-dns

My home DNS stack running on [Fedora IoT](https://fedoraproject.org/iot/) and managed by podman and systemd

## Fedora IoT

1. Install base system deps and reboot ...

    ```sh
    sudo rpm-ostree install --idempotent --assumeyes curl git go-task
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

6. Disable `systemd-resolved`, update `/etc/resolv.conf` and reboot ...

    ```sh
    export DOMAIN="turbo.ac"
    sudo systemctl mask systemd-resolved.service
    sudo rm -rf /etc/resolv.conf
    sudo --preserve-env bash -c 'cat << EOF > /etc/resolv.conf
    nameserver 1.1.1.1
    domain $DOMAIN
    search $DOMAIN
    EOF'
    sudo chattr +i /etc/resolv.conf
    sudo systemctl reboot
    ```

## Apps

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

3. Edit `./containers/bind/data/config/named.conf` with your included keys and zones.

4. Update `./containers/bind/data/config/zones` with your DNS configuration.

5. Attempt to run bind

    ```sh
    go-task start-bind
    ```

### blocky

> [!IMPORTANT]
> Blocky can take awhile to start depending on how many blocklists you have configured

1. Edit `./etc/containers/systemd/blocky/config/config.yaml` with your bind IP address for `.clientLookup.upstream`

2. Change any other configuration you want (e.g. blocklists)

3. Attempt to run blocky

    ```sh
    go-task start-blocky
    ```

### dnsdist

1. Edit `./etc/containers/systemd/dnsdist/config/dnsdist.conf` and update the IP addresses for bind and blocky.

2. Change the actions to suit your networks.

3. Attempt to run dnsdist

    ```sh
    go-task start-dnsdist
    ```

## Testing

```sh
dig @192.168.1.50 -p 53 google.com         # dnsdist external query
dig @192.168.1.50 -p 53 expanse.turbo.ac   # dnsdist internal query
dig @192.168.1.50 -p 5301 google.com       # blocky external query
dig @192.168.1.50 -p 5301 expanse.turbo.ac # blocky internal query
dig @192.168.1.50 -p 5300 google.com       # bind external query
dig @192.168.1.50 -p 5300 expanse.turbo.ac # bind internal query
```
