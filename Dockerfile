FROM ubuntu:25.04

ENV DEBIAN_FRONTEND=noninteractive

# Essential build tools and dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential cmake pkg-config git mingw-w64 curl wget gnupg ca-certificates openssh-client openssh-server sudo

# config ssh
RUN mkdir /var/run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

ENV ROOT_PASSWORD=devcontainer

RUN echo "root:${ROOT_PASSWORD}" | chpasswd

# GLFW
RUN apt-get install -y --no-install-recommends libgl-dev wayland-protocols libwayland-bin libwayland-dev libxkbcommon-dev libxrandr-dev \
        libxinerama-dev libxcursor-dev libxi-dev pkg-config mingw-w64 mingw-w64-x86-64-dev libgl1-mesa-dev
# Vulkan
RUN curl -fsSL https://packages.lunarg.com/lunarg-signing-key-pub.asc | gpg --dearmor -o /usr/share/keyrings/lunarg.gpg && \
    wget -qO /etc/apt/sources.list.d/lunarg-vulkan.list https://packages.lunarg.com/vulkan/1.3.296/lunarg-vulkan-1.3.296-noble.list && \
    sed -i 's#https://packages.lunarg.com/vulkan/1.3.296#\[signed-by=/usr/share/keyrings/lunarg.gpg] https://packages.lunarg.com/vulkan/1.3.296#' \
        /etc/apt/sources.list.d/lunarg-vulkan.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends vulkan-utility-libraries-dev libvulkan-dev vulkan-tools vulkan-validationlayers
# GLM
RUN apt-get install -y --no-install-recommends libglm-dev
# GLS Lang Validator
RUN apt-get install -y --no-install-recommends glslang-tools
# Assimp
RUN apt-get install -y --no-install-recommends libassimp-dev
# Embedded libs
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apt-file \
        libdecor-0-0 \
        libdecor-0-plugin-1-gtk \
        libdecor-0-plugin-1-cairo \
        libgtk-3-0 \
        gnome-themes-extra-data && \
    apt-file update && \
    DEST=lib/linux && \
    mkdir -p "$DEST/share" && \
    \
    # libs principais
    LIBS="libgtk-3.so.0 libgdk-3.so.0 libdecor-0.so.0" && \
    \
    # libs proibidas (NUNCA copiar)
    BLOCKED="libc.so libm.so ld-linux libpthread.so libgcc_s.so librt.so libdl.so libstdc++.so" && \
    \
    for lib in $LIBS; do \
        src="/usr/lib/x86_64-linux-gnu/$lib"; \
        cp "$src" "$DEST/"; \
        \
        # pegar dependências seguras
        ldd "$src" | awk '{print $3}' | grep -E '^/' | while read dep; do \
            base=$(basename "$dep"); \
            skip=false; \
            for bad in $BLOCKED; do \
                case "$base" in \
                    $bad*) skip=true ;; \
                esac; \
            done; \
            \
            if [ "$skip" = false ]; then \
                cp -u "$dep" "$DEST/" 2>/dev/null || true; \
            fi; \
        done; \
    done && \
    \
    # plugins do libdecor
    mkdir -p "$DEST/libdecor/plugins-1" && \
    cp /usr/lib/x86_64-linux-gnu/libdecor/plugins-1/* "$DEST/libdecor/plugins-1/" && \
    \
    # temas e dados gtk
    mkdir -p "$DEST/share/themes" && \
    cp -r /usr/share/themes/Adwaita "$DEST/share/themes/" && \
    \
    mkdir -p "$DEST/share/gtk-3.0" && \
    cp -r /usr/share/gtk-3.0/* "$DEST/share/gtk-3.0/" && \
    \
    mkdir -p "$DEST/share/glib-2.0/schemas" && \
    cp -r /usr/share/glib-2.0/schemas/* "$DEST/share/glib-2.0/schemas/"

# vscode
RUN mkdir -p /root/.vscode-server/server
RUN curl -L https://update.code.visualstudio.com/latest/server-linux-x64/stable \
    | tar -xz -C /root/.vscode-server/server --strip-components=1

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

CMD ["sh", "-c", "service ssh start && bash"]