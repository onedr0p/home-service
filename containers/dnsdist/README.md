# dnsdist

https://dnsdist.org

## Configuration

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
