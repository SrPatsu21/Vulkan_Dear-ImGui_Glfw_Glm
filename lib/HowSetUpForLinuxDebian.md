# Set Up for linux debian

## libs

```shell
mkdir -p lib/
```

### Dear ImGui

```shell
# Download
wget -P lib/ "https://github.com/ocornut/imgui/archive/refs/tags/v1.92.8.zip" && \
# Unzip file
unzip lib/v1.92.8.zip -d lib/ && \
# Rename
mv lib/imgui-1.92.8 lib/Dear-ImGui && \
# Remove zip file
rm lib/v1.92.8.zip
```

### GLFW

```shell
# Download
wget -P lib/ "https://github.com/glfw/glfw/releases/download/3.4/glfw-3.4.zip" && \
# Unzip
unzip lib/3.4.zip -d lib/ && \
# Rename
mv lib/glfw-3.4 lib/glfw && \
# Remove zip file
rm lib/3.4.zip
```

```shell
# lib
sudo apt install -y libgl-dev && \
# Install wayland
sudo apt install -y wayland-protocols libwayland-bin libwayland-dev && \
# Install xkbcommon
sudo apt install -y libxkbcommon-dev && \
# Install libxrandr
sudo apt install -y libxrandr-dev && \
# Install libxinerama
sudo apt install -y libxinerama-dev && \
# Install libxcursor
sudo apt install -y libxcursor-dev && \
# Install libxi
sudo apt install -y libxi-dev && \
# Install pkg-config
sudo apt install -y pkg-config && \
# Install mingw-w64
sudo apt install -y mingw-w64 mingw-w64-x86-64-dev && \
# Install libgl1-mesa-dev
sudo apt install -y libgl1-mesa-dev
```

### Vulkan

```shell
# install
sudo apt install -y
    git \
    cmake \
    mingw-w64 \
    libvulkan-dev \
    vulkan-tools \
    vulkan-validationlayers \
    glslang-tools && \
# Download Vulkan for windows crosscomplile
git clone --branch v1.4.352 https://github.com/KhronosGroup/Vulkan-Headers.git lib/Vulkan-Headers && \
git clone --branch v1.4.352 https://github.com/KhronosGroup/Vulkan-Loader.git lib/Vulkan-Loader
```

### GLM

```shell
# install
sudo apt install -y libglm-dev && \
# windows cross compile
wget -P lib/ "https://github.com/g-truc/glm/releases/download/1.0.3/glm-1.0.3.zip" && \
7z x lib/1.0.3.zip -o./lib/glm && \
rm lib/1.0.3.zip
```

### STD

```shell
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
```

### GLS Lang Validator

```shell
sudo apt install -y glslang-tools
```

### Assimp

```shell
sudo apt-get install libassimp-dev
# windows cross compile
wget -P lib/ https://github.com/assimp/assimp/archive/refs/tags/v6.0.5.zip
7z x lib/v6.0.5.zip -o./lib/assimp
mv lib/assimp/assimp-6.0.5/* lib/assimp/
rm -R lib/assimp/assimp-6.0.5
rm lib/v6.0.5.zip
```

### KTX-Software

```shell
cd lib/
curl -L -O https://github.com/KhronosGroup/KTX-Software/archive/refs/tags/v4.4.2.zip
unzip v4.4.2.zip
rm v4.4.2.zip
mv KTX-Software-4.4.2 KTX-Software
```

### Embedded libs

```shell
sudo apt install -y apt-file
sudo apt-file update
sudo apt install -y libdecor-0-0 libdecor-0-plugin-1-gtk libdecor-0-plugin-1-cairo
sudo apt install -y libgtk-3-0
sudo apt install -y gnome-themes-extra-data
```

```shell
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
```

## Build

- build

```shell
mkdir build
cd build
cmake ..
make -j$(nproc)
```

- fix wayland if needed

```shell
cat << 'EOF' > run.sh
HERE="$(dirname "$(readlink -f "$0")")"

export GTK_THEME=Adwaita
export XDG_DATA_DIRS="$HERE/lib/linux/share:/usr/share"
export GDK_BACKEND=wayland,x11
export LD_LIBRARY_PATH="$HERE/lib/linux:$LD_LIBRARY_PATH"

"$HERE/ProjectName"
EOF
chmod +x run.sh
```

## Build for Windows

```bash
mkdir build-windows
cd build-windows
cmake .. -D CMAKE_TOOLCHAIN_FILE=../toolchain-mingw.cmake
make -j$(nproc)
```
<!-- could be util
-D UPDATE_DEPS=ON
-->

## Build Release

- build

```shell
mkdir build-release
cd build-release
cmake .. -DCMAKE_BUILD_TYPE=Release # for realease
make -j$(nproc)
```

- fix wayland

```shell
cat << 'EOF' > run.sh
HERE="$(dirname "$(readlink -f "$0")")"

export GTK_THEME=Adwaita
export XDG_DATA_DIRS="$HERE/lib/linux/share:/usr/share"
export GDK_BACKEND=wayland,x11
export LD_LIBRARY_PATH="$HERE/lib/linux:$LD_LIBRARY_PATH"

"$HERE/ProjectName."
EOF
chmod +x run.sh
```

## Build for Windows Release

```bash
mkdir build-windows-release
cd build-windows-release
cmake .. -D CMAKE_TOOLCHAIN_FILE=../toolchain-mingw.cmake -DCMAKE_BUILD_TYPE=Release # for realease
make -j$(nproc)
```
<!-- could be util
-D UPDATE_DEPS=ON
-->
