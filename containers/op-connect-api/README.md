# onepassword

https://github.com/1Password/connect

## Configuration

1. Add your `./containers/op-connect-api/data/config/1password-credentials.sops.json` configuration and encrypted it with sops

    ```sh
    sops --encrypt --in-place ./containers/op-connect-api/data/config/1password-credentials.sops.json
    ```

2. Start `op-connect-api` and `op-connect-sync`

    ```sh
    task start-op-connect-api
    task start-op-connect-sync
    ```
