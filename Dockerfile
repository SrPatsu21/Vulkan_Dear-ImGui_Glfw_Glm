FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

# ---------------------------------------------------------------------------
# Third-party library versions (bump here, rebuild the image, done).
# Always double-check the latest tags before releasing a new image version.
# ---------------------------------------------------------------------------
# https://vulkan.lunarg.com/sdk/home
ARG VULKAN_VERSION=1.4.363
# https://www.glfw.org/
ARG GLFW_VERSION=3.5.1
# https://github.com/ocornut/imgui/releases
ARG IMGUI_VERSION=v1.93.0
# https://github.com/g-truc/glm/releases
ARG GLM_VERSION=1.0.3
# https://github.com/assimp/assimp/releases
ARG ASSIMP_VERSION=v6.0.6
# github.com/KhronosGroup/KTX-Software/releases
ARG KTX_VERSION=v4.4.2
# stb has no release tags, so pin a commit (or leave "master" for the latest)
ARG STB_REF=master

# Libs live inside the image at the same path CMakeLists.txt already uses
# (/workspace/lib), so the IDE attached to the container resolves them
ENV LIB_DIR=/workspace/lib
# Root folder for build trees (the build scripts read this variable)
ENV BUILD_ROOT=/build

# Toolchains and system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential cmake pkg-config git curl wget gnupg \
        ca-certificates openssh-client openssh-server \
        mingw-w64 mingw-w64-x86-64-dev \
        libgl-dev libgl1-mesa-dev wayland-protocols libwayland-bin libwayland-dev \
        libxkbcommon-dev libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev \
        libvulkan-dev vulkan-tools vulkan-validationlayers glslang-tools \
        libglm-dev zlib1g-dev \
        libdecor-0-0 libdecor-0-plugin-1-gtk libdecor-0-plugin-1-cairo \
        libgtk-3-0 gnome-themes-extra-data && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Third-party libs, fetched at image build time and kept only inside the image
RUN mkdir -p ${LIB_DIR} && cd ${LIB_DIR} && \
    git clone --depth 1 --branch v${VULKAN_VERSION} https://github.com/KhronosGroup/Vulkan-Headers.git && \
    git clone --depth 1 --branch v${VULKAN_VERSION} https://github.com/KhronosGroup/Vulkan-Loader.git && \
    git clone --depth 1 --branch ${GLFW_VERSION} https://github.com/glfw/glfw.git && \
    git clone --depth 1 --branch ${IMGUI_VERSION} https://github.com/ocornut/imgui.git Dear-ImGui && \
    git clone --depth 1 --branch ${GLM_VERSION} https://github.com/g-truc/glm.git glm/glm-${GLM_VERSION} && \
    git clone --depth 1 --branch ${ASSIMP_VERSION} https://github.com/assimp/assimp.git && \
    git clone --depth 1 --branch ${KTX_VERSION} --recurse-submodules --shallow-submodules \
        https://github.com/KhronosGroup/KTX-Software.git && \
    git clone --depth 1 --branch ${STB_REF} https://github.com/nothings/stb.git && \
    find ${LIB_DIR} -name .git -prune -exec rm -rf {} +

# SSH: root login with password, but the password comes from a Docker secret
# at runtime (see docker-entrypoint.sh)
RUN mkdir -p /run/sshd && \
    printf 'PermitRootLogin yes\nPasswordAuthentication yes\n' \
        > /etc/ssh/sshd_config.d/10-builder.conf

WORKDIR /workspace

# Only the project files are copied; libs are already in /workspace/lib
COPY CMakeLists.txt toolchain-mingw.cmake /workspace/
COPY scripts /workspace/scripts
COPY src /workspace/src
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /workspace/scripts/*.sh /usr/local/bin/docker-entrypoint.sh && \
    mkdir -p ${BUILD_ROOT}

VOLUME ["/build"]

# ssh
EXPOSE 22

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["bash"]