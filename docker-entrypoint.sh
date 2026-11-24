#!/usr/bin/env bash
# Container entrypoint.
# Reads the root SSH password from a Docker secret (file) instead of an
# environment variable, then starts sshd and hands control to the CMD.
set -euo pipefail

SECRET_FILE="${ROOT_PASSWORD_FILE:-/run/secrets/ssh_root_password}"

if [[ -f "$SECRET_FILE" ]]; then
    # Never echo the password; feed it to chpasswd through stdin only
    printf 'root:%s\n' "$(< "$SECRET_FILE")" | chpasswd
else
    # No secret provided: disable password login instead of leaving a weak default
    echo "[entrypoint] Secret '$SECRET_FILE' not found; SSH password login disabled." >&2
    sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' \
        /etc/ssh/sshd_config.d/10-builder.conf
fi

mkdir -p /run/sshd
/usr/sbin/sshd

exec "$@"