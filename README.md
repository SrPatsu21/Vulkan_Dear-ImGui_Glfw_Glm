# Vulkan Dear-ImGui Glfw Glm

Container to compile everything together

## script to make a start setup

- Linux

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
          cp -r /workspace/* /copy-dest/ || true
          cp -r /root/.vscode-server/extensions /copy-dest/vscode-extensions/ || true
      "

  echo "files from container copied to $DEST"
  ```

- Windows

  ```shell
  $ErrorActionPreference = "Stop"

  $image = "srpatsu21/dear-glfw-vulkan-compiler:latest"
  $dest = "."

  if (-not (Test-Path $dest)) {
      New-Item -ItemType Directory -Path $dest | Out-Null
  }
  $vscodeDir = Join-Path $dest "vscode-extensions"
  if (-not (Test-Path $vscodeDir)) {
      New-Item -ItemType Directory -Path $vscodeDir | Out-Null
  }

  docker run --rm -v "${PWD}\$dest:/copy-dest" $image `
      bash -c "
          cp -r /workspace/* /copy-dest/ || true
          cp -r /root/.vscode-server/extensions /copy-dest/vscode-extensions/ || true
      "

  Write-Host "Files from container copied to $dest"
  ```

## Docker Compose setup

- docker-compose.yml

```yaml
services:
    dear-glfw-vulkan-compiler:
        image: srpatsu21/dear-glfw-vulkan-compiler:1.3.0
        container_name: dear-glfw-vulkan-dev
        stdin_open: true
        tty: true
        working_dir: /workspace
        environment:
            # ssh pass
            ROOT_PASSWORD: 123
        ports:
            # ssh port
            - "2222:22"

        volumes:
            # create build files
            - ./build:/workspace/build
            - ./build-release:/workspace/build-release
            - ./build-windows:/workspace/build-windows
            - ./build-windows-release:/workspace/build-windows-release

            # map your libs and config
            - ./CMakeLists.txt:/workspace/CMakeLists.txt
            - ./toolchain-mingw.cmake:/workspace/toolchain-mingw.cmake
            - ./lib:/workspace/lib

            # make src interactive
            - ./src:/workspace/src

            # if you want to replace the scripts
            - ./scripts:/workspace/scripts
```

- Acess the container to compile

```shell
docker compose up -d
docker exec -it dear-glfw-vulkan-dev bash
```

or you can acess by vscode or ssh

- run script
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
