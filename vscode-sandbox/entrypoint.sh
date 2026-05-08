#!/bin/bash
set -euo pipefail

_USER="${USERNAME:-whil}"
SSH_DIR="/home/${_USER}/.ssh"
AUTH_KEYS="${SSH_DIR}/authorized_keys"

# Fix home dir ownership/perms — PVC mount resets these to root:root 777
chown "${_USER}:${_USER}" "/home/${_USER}"
chmod 750 "/home/${_USER}"

# Ensure .ssh dir exists with correct perms
mkdir -p "${SSH_DIR}"
chmod 700 "${SSH_DIR}"

# Recover if authorized_keys was somehow created as a directory
if [[ -d "${AUTH_KEYS}" ]]; then
    rm -rf "${AUTH_KEYS}"
fi

# Ensure the file exists
touch "${AUTH_KEYS}"

# Inject keys from AUTHORIZED_KEYS env var
if [[ -n "${AUTHORIZED_KEYS:-}" ]]; then
    echo "${AUTHORIZED_KEYS}" >> "${AUTH_KEYS}"
fi

# Merge any key files from /authorized_keys.d/
if [[ -d /authorized_keys.d ]]; then
    for f in /authorized_keys.d/*; do
        [[ -f "$f" ]] && cat "$f" >> "${AUTH_KEYS}"
    done
fi

# Deduplicate, fix ownership and perms
sort -u "${AUTH_KEYS}" -o "${AUTH_KEYS}"
chown -R "${_USER}:${_USER}" "${SSH_DIR}"
chmod 600 "${AUTH_KEYS}"

if [[ ! -s "${AUTH_KEYS}" ]]; then
    echo "WARNING: authorized_keys is empty — no keys will be accepted" >&2
fi

# Generate host keys if missing (first boot)
ssh-keygen -A

exec /usr/sbin/sshd -D -e
