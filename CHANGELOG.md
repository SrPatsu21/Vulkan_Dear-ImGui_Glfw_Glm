# Changelog - dear-glfw-vulkan-compiler

## [2.0.0] - 2026-11-24

### Changed

- Base image: `ubuntu:25.04 -> ubuntu:26.04`
- Libs are now downloaded during the image build and live **only inside the image**
  at `/workspace/lib` (no `lib/` folder or volume needed on the host); the IDE
  attached to the container still resolves everything from there
- Each lib version is an `ARG` at the top of the `Dockerfile`
- Build trees are now created under `BUILD_ROOT` (`/build` in the container),
  mapped to `./out` on the host, instead of four folders in the project root
- Start setup scripts no longer copy `lib/` out of the image
- SSH password is now read from a Docker secret (`ROOT_PASSWORD_FILE`,
  default `/run/secrets/ssh_root_password`); with no secret, SSH password login
  is disabled

### Removed

- `ROOT_PASSWORD` environment variable
- `vscode-extensions` copy step from the docs
- `lib` and `build*` volumes from `docker-compose.yml`
- Unused apt packages: `libassimp-dev`, `apt-file`, `sudo`

---

## [1.3.0] - 2026-06-02

### Added

- Libs
  - **Dear ImGui**: `v1.92.2b -> v1.92.8`
  - **Vulakn**: change to Vulkan-Headers & Vulkan-Loader
  - Vulkan-Headers: `v1.4.352`
  - Vulkan-Loader: `v1.4.352`
  - glm: `1.0.1 -> 1.0.3`
  - Assimp: `v5.3.1 -> v6.0.5`
- Scripts
  - make multi-threading

### Fixed

- SSH password can now be defined by ENV

---

## [1.2.0] - 2026-05-29

### Added

- SSH Conections

---

## [1.1.0] - ?

### Added

- KTX-Software

---

## [1.0.0] - ?

### Added

- First version
