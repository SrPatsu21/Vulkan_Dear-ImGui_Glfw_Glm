# How to create new version

1. Copy old env

    ```shell
    set -e

    IMAGE="srpatsu21/dear-glfw-vulkan-compiler:latest"
    DEST="."

    mkdir -p "$DEST"
    mkdir -p "$DEST/vscode-extensions"

    docker run --rm \
        -v "$(pwd)/$DEST":/copy-dest \
        "$IMAGE" \
        bash -c "
            cp -r /root/.vscode-server/extensions /copy-dest/vscode-extensions/ || true
        "

    echo "files from container copied to $DEST"
    ```

2. Change the env as you want

3. build image

    ```shell
    docker build -t srpatsu21/dear-glfw-vulkan-compiler:latest .
    ```

4. Run the scripts to compile for:

    - Linux Debug

        ```shell
        ./scripts/build_linux.sh
        ```

    - Linux Release

        ```shell
        ./scripts/build_linux_release.sh
        ```

    - Windows Debug

        ```shell
        ./scripts/build_windows.sh
        ```

    - Windows Release

        ```shell
        ./scripts/build_windows_release.sh
        ```

    - Others scripts

        ```shell
            ./scripts/build_all_debug.sh
            ./scripts/build_all_release.sh
            ./scripts/build_all.sh
        ```
