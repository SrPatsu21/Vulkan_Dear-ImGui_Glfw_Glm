# How to create new version

Current version: **2.0.0**

1. Change the env as you want

    - Library versions are `ARG`s at the top of the `Dockerfile`
      (`VULKAN_VERSION`, `GLFW_VERSION`, `IMGUI_VERSION`, `GLM_VERSION`,
      `ASSIMP_VERSION`, `KTX_VERSION`, `STB_REF`). Check the latest tags and bump
      them there. The libs are cloned into `/workspace/lib` inside the image.
    - Keep `VULKAN_VERSION` and `VulkanHeaders_VERSION` in `CMakeLists.txt` in sync.
    - The base image is `ubuntu:26.04`; system packages are installed in the
      `Dockerfile`.
    - Update the version in `CHANGELOG.md` and in the image tag of
      `docker-compose.yml` and `README.md`.

2. Build the image (the libs are downloaded during the build, so it needs internet)

    ```shell
    docker build -t srpatsu21/dear-glfw-vulkan-compiler:2.0.0 \
                 -t srpatsu21/dear-glfw-vulkan-compiler:latest .
    ```

    To override a lib version without editing the `Dockerfile`:

    ```shell
    docker build --build-arg GLFW_VERSION=3.4 \
                 -t srpatsu21/dear-glfw-vulkan-compiler:2.0.0 .
    ```

3. Create the SSH secret and start the container

    ```shell
    ./scripts/setup_secrets.sh
    docker compose up -d
    docker exec -it dear-glfw-vulkan-dev bash
    ```

4. Run the scripts to compile for (output goes to `./out/...`):

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

5. Publish the image

    ```shell
    docker push srpatsu21/dear-glfw-vulkan-compiler:2.0.0
    docker push srpatsu21/dear-glfw-vulkan-compiler:latest
    ```
