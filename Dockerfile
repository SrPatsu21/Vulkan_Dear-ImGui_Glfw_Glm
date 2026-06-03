FROM ubuntu:25.04

ENV DEBIAN_FRONTEND=noninteractive

# Essential build tools and dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential cmake pkg-config git mingw-w64 curl wget gnupg ca-certificates openssh-client openssh-server sudo

# config ssh
RUN mkdir /var/run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# libs from apt
RUN sudo apt-get install -y --no-install-recommends libgl-dev wayland-protocols libwayland-bin libwayland-dev libxkbcommon-dev libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev pkg-config mingw-w64 mingw-w64-x86-64-dev libgl1-mesa-dev git cmake libvulkan-dev vulkan-tools vulkan-validationlayers glslang-tools libglm-dev apt-file libdecor-0-0 libdecor-0-plugin-1-gtk libdecor-0-plugin-1-cairo libgtk-3-0 gnome-themes-extra-data libassimp-dev

# Remove apt list
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apt/*

# Set working directory for project
WORKDIR /workspace

# Copy only build-related files (libs, scripts, cmake)
COPY lib /workspace/lib
COPY scripts /workspace/scripts
COPY CMakeLists.txt /workspace/
COPY toolchain-mingw.cmake /workspace/
COPY src /workspace/src
COPY vscode-extensions /root/.vscode-server/extensions/


# Make scripts executable
RUN chmod +x /workspace/scripts/*.sh

# Declare build folders as exportable volumes
VOLUME ["/workspace/build", "/workspace/build-release", "/workspace/build-windows", "/workspace/build-windows-release"]

# ssh
EXPOSE 22

# Dockerfile (no ROOT_PASSWORD here)
CMD ["sh", "-c", "echo \"root:${ROOT_PASSWORD}\" | chpasswd && service ssh start && bash"]
