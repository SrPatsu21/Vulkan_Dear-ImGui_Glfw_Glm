# Vulkan Dear-ImGui Glfw Glm

Container to compile everything together (Linux and Windows, Debug and Release).

All third-party libraries (Vulkan, GLFW, Dear ImGui, GLM, Assimp, KTX, stb) live
**inside the image** at `/workspace/lib`. You do not need a `lib/` folder on your
machine. Attach your IDE to the container (VS Code or SSH) and it resolves
everything from there.

## Start setup

Copies the project files (`CMakeLists.txt`, `toolchain-mingw.cmake`, `src`,
`scripts`) out of the image. The libs are **not** copied.

- Linux

  ```shell
  set -e

  IMAGE="srpatsu21/dear-glfw-vulkan-compiler:2.0.0"
  DEST="."

  mkdir -p "$DEST"

  docker run --rm \
      -v "$(pwd)/$DEST":/copy-dest \
      "$IMAGE" \
      bash -c "
          cp -r /workspace/CMakeLists.txt /workspace/toolchain-mingw.cmake \
                /workspace/src /workspace/scripts /copy-dest/
      "

  echo "files from container copied to $DEST"
  ```

- Windows

  ```shell
  $ErrorActionPreference = "Stop"

  $image = "srpatsu21/dear-glfw-vulkan-compiler:2.0.0"
  $dest = "."

  if (-not (Test-Path $dest)) {
      New-Item -ItemType Directory -Path $dest | Out-Null
  }

  docker run --rm -v "${PWD}\$dest:/copy-dest" $image `
      bash -c "
          cp -r /workspace/CMakeLists.txt /workspace/toolchain-mingw.cmake /workspace/src /workspace/scripts /copy-dest/
      "

  Write-Host "Files from container copied to $dest"
  ```

## SSH password (Docker secret)

The root SSH password is not stored in `docker-compose.yml`. It is read from a
Docker secret file. Create the file once, replacing `your-password` with the
password you want:

- Linux

  ```shell
  mkdir -p secrets build
  printf '%s' 'your-password' > secrets/ssh_root_password.txt
  chmod 600 secrets/ssh_root_password.txt
  printf 'secrets/\nbuild/\n' >> .gitignore
  ```

- Windows

  ```shell
  New-Item -ItemType Directory -Force secrets, build | Out-Null
  Set-Content -NoNewline -Path secrets\ssh_root_password.txt -Value 'your-password'
  Add-Content -Path .gitignore -Value "secrets/", "build/"
  ```

If the secret file is missing, the container still starts, but SSH password
login is disabled.

## Docker Compose setup

- docker-compose.yml

```yaml
services:
    dear-glfw-vulkan-compiler:
        image: srpatsu21/dear-glfw-vulkan-compiler:2.0.0
        container_name: dear-glfw-vulkan-dev
        stdin_open: true
        tty: true
        working_dir: /workspace
        environment:
            # Path of the secret file inside the container (no password in env)
            ROOT_PASSWORD_FILE: /run/secrets/ssh_root_password
            # Root folder for build trees inside the container
            BUILD_ROOT: /build
        secrets:
            - ssh_root_password
        ports:
            # ssh port
            - "2222:22"
        volumes:
            # Build trees (build, build-release, build-windows, ...) are created
            # here; change the host path to move them
            - ./build:/build

            # Project files you edit on the host (libs are NOT mounted)
            - ./CMakeLists.txt:/workspace/CMakeLists.txt
            - ./toolchain-mingw.cmake:/workspace/toolchain-mingw.cmake
            - ./src:/workspace/src
            - ./scripts:/workspace/scripts

secrets:
    ssh_root_password:
        # Plain-text file containing only the password; see "SSH password" above
        file: ./secrets/ssh_root_password.txt
```

- Access the container to compile

```shell
docker compose up -d
docker exec -it dear-glfw-vulkan-dev bash
```

or you can access it by VS Code or SSH (`ssh root@localhost -p 2222`, using the
password from the secret file).

- Run script
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

## Build output

Build trees are created under `BUILD_ROOT` (`/build` in the container), which is
mapped to `./build` on the host:

| Script                        | Folder                      |
| ----------------------------- | --------------------------- |
| `build_linux.sh`              | `out/build`                 |
| `build_linux_release.sh`      | `out/build-release`         |
| `build_windows.sh`            | `out/build-windows`         |
| `build_windows_release.sh`    | `out/build-windows-release` |

To build somewhere else, change the `./build:/build` volume in `docker-compose.yml`.