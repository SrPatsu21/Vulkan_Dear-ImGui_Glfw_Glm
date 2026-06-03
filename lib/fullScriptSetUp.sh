mkdir -p lib/

sudo apt-get install -y --no-install-recommends libgl-dev wayland-protocols libwayland-bin libwayland-dev libxkbcommon-dev libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev pkg-config mingw-w64 mingw-w64-x86-64-dev libgl1-mesa-dev git cmake libvulkan-dev vulkan-tools vulkan-validationlayers glslang-tools libglm-dev apt-file libdecor-0-0 libdecor-0-plugin-1-gtk libdecor-0-plugin-1-cairo libgtk-3-0 gnome-themes-extra-data libassimp-dev

# Dear ImGui

wget -P lib/ "https://github.com/ocornut/imgui/archive/refs/tags/v1.92.8.zip" && \
unzip lib/v1.92.8.zip -d lib/ && \
mv lib/imgui-1.92.8 lib/Dear-ImGui && \
rm lib/v1.92.8.zip

# GLFW

wget -P lib/ "https://github.com/glfw/glfw/releases/download/3.4/glfw-3.4.zip" && \
unzip lib/3.4.zip -d lib/ && \
mv lib/glfw-3.4 lib/glfw && \
rm lib/3.4.zip

# Vulkan
git clone --branch v1.4.352 https://github.com/KhronosGroup/Vulkan-Headers.git lib/Vulkan-Headers && \
git clone --branch v1.4.352 https://github.com/KhronosGroup/Vulkan-Loader.git lib/Vulkan-Loader

# GLM

wget -P lib/ "https://github.com/g-truc/glm/releases/download/1.0.3/glm-1.0.3.zip" && \
7z x lib/1.0.3.zip -o./lib/glm && \
rm lib/1.0.3.zip

# STD

mkdir -p lib/stb &&
cd lib/stb &&
curl -O https://raw.githubusercontent.com/nothings/stb/master/stb_image.h &&
curl -O https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h &&
curl -O https://raw.githubusercontent.com/nothings/stb/master/stb_image_resize.h &&
curl -O https://raw.githubusercontent.com/nothings/stb/master/stb_truetype.h &&
curl -O https://raw.githubusercontent.com/nothings/stb/master/stb_rect_pack.h &&
curl -O https://raw.githubusercontent.com/nothings/stb/master/stb_sprintf.h &&
curl -O https://raw.githubusercontent.com/nothings/stb/master/stb_perlin.h &&
curl -O https://raw.githubusercontent.com/nothings/stb/master/stb_textedit.h &&
cd ../..

# Assimp


wget -P lib/ https://github.com/assimp/assimp/archive/refs/tags/v6.0.5.zip && \
7z x lib/v6.0.5.zip -o./lib/assimp  && \
mv lib/assimp/assimp-6.0.5/* lib/assimp/  && \
rm -R lib/assimp/assimp-6.0.5  && \
rm lib/v6.0.5.zip

# KTX-Software

cd lib/  && \
curl -L -O https://github.com/KhronosGroup/KTX-Software/archive/refs/tags/v4.4.2.zip  && \
unzip v4.4.2.zip  && \
rm v4.4.2.zip  && \
mv KTX-Software-4.4.2 KTX-Software

### Embedded libs

DEST=lib/linux
mkdir -p "$DEST/share"

LIBS=(
    libgtk-3.so.0
    libgdk-3.so.0
    libdecor-0.so.0
)

BLOCKED=(
    libc.so
    libm.so
    ld-linux
    libpthread.so
    libgcc_s.so
    librt.so
    libdl.so
    libstdc++.so
)

for lib in "${LIBS[@]}"; do
    src="/usr/lib/x86_64-linux-gnu/$lib"
    cp "$src" "$DEST/"

    # search for dependencies
    ldd "$src" | awk '{print $3}' | grep -E '^/' | while read dep; do
        base=$(basename "$dep")

        # check if blocked
        skip=false
        for bad in "${BLOCKED[@]}"; do
            if [[ "$base" == $bad* ]]; then
                skip=true
                break
            fi
        done

        if [[ $skip == false ]]; then
            cp -u "$dep" "$DEST/" 2>/dev/null || true
        fi
    done
done

# copiar plugins e temas (seguros)
mkdir -p "$DEST/libdecor/plugins-1"
cp /usr/lib/x86_64-linux-gnu/libdecor/plugins-1/* "$DEST/libdecor/plugins-1/"

mkdir -p "$DEST/share/themes"
cp -r /usr/share/themes/Adwaita "$DEST/share/themes/"

mkdir -p "$DEST/share/gtk-3.0"
cp -r /usr/share/gtk-3.0/* "$DEST/share/gtk-3.0/"

mkdir -p "$DEST/share/glib-2.0/schemas"
cp -r /usr/share/glib-2.0/schemas/* "$DEST/share/glib-2.0/schemas/"
