# podman-exporter

https://github.com/containers/prometheus-podman-exporter

## Configuration

1. Enable the `podman.socket` service

    ```sh
    sudo systemctl enable --now podman.socket
    ```

2. Start `podman-exporter`

    ```sh
    task start-podman-exporter
    ```
