# whil-docker-images

[![CI](https://github.com/whilcayangyang/whil-docker-images/actions/workflows/docker-build.yaml/badge.svg)](https://github.com/whilcayangyang/whil-docker-images/actions/workflows/docker-build.yaml)
[![GHCR](https://img.shields.io/badge/registry-ghcr.io-blue?logo=github)](https://github.com/whilcayangyang?tab=packages)
[![License: GPL v3](https://img.shields.io/badge/license-GPLv3-blue.svg)](LICENSE)

A collection of container images built and published to GHCR via GitHub Actions.

---

## Images

### `vscode-sandbox 263.38 MB  (0.26 GB) `

[![ghcr: vscode-sandbox](https://img.shields.io/badge/ghcr.io-vscode--sandbox-blue?logo=docker&logoColor=white)](https://github.com/whilcayangyang/whil-docker-images/pkgs/container/whil-docker-images%2Fvscode-sandbox)

A Debian-based SSH remote development container pre-loaded with infrastructure tooling, designed for use as a [VS Code Remote - SSH](https://code.visualstudio.com/docs/remote/ssh) target.

```
ghcr.io/whilcayangyang/whil-docker-images/vscode-sandbox:latest
```

<details>
<summary>Included tools</summary>

| Tool | Version | Source |
|------|---------|--------|
| Terraform | 1.15.2 | binary (releases.hashicorp.com) |
| TFLint | latest | binary (install script) |
| Trivy | latest | binary (install script) |
| terraform-docs | v0.23.0 | binary |
| Hugo | 0.161.1 | binary |
| Python 3 / pip / venv | system | Debian repo |
| Node.js / npm | system | Debian repo |
| Git, curl | system | Debian repo |

</details>

---

---

### `fedora-devops-toolbox 890.21 MB  (0.87 GB) `

[![ghcr: fedora-devops-toolbox](https://img.shields.io/badge/ghcr.io-fedora--devops--toolbox-blue?logo=docker&logoColor=white)](https://github.com/whilcayangyang/whil-docker-images/pkgs/container/whil-docker-images%2Ffedora-devops-toolbox)

A Fedora 44 toolbox image for [Silverblue](https://fedoraproject.org/silverblue/) / [distrobox](https://distrobox.it/) with DevOps tooling pre-installed. Built with a multi-stage Dockerfile to keep the final image lean.

```
ghcr.io/whilcayangyang/whil-docker-images/fedora-devops-toolbox:latest
```

<details>
<summary>Included tools</summary>

| Tool | Version | Source |
|------|---------|--------|
| kubectl | latest | Fedora repo |
| helm | latest | Fedora repo |
| k9s | latest | Fedora repo |
| ansible | latest | Fedora repo |
| hugo | latest | Fedora repo |
| go-task | latest | Fedora repo |
| restic | latest | Fedora repo |
| rclone | latest | Fedora repo |
| age | latest | Fedora repo |
| git, curl, jq, yq | latest | Fedora repo |
| Node.js / npm | latest | Fedora repo |
| Python 3 / pip | latest | Fedora repo |
| zsh + plugins | latest | Fedora repo |
| fastfetch | latest | Fedora repo |
| terraform | 1.15.2 | binary |
| tflint | latest | binary |
| trivy | latest | binary |
| terraform-docs | v0.23.0 | binary |
| talosctl | latest | binary (talos.dev/install) |
| kubeseal | 0.36.6 | binary |
| flux | 2.8.6 | binary |
| sops | 3.13.1 | binary |

</details>

**Shell — zsh + Oh My Zsh**

`zsh`, `zsh-autosuggestions`, and `zsh-syntax-highlighting` are installed in the image. Since toolbox mounts your host `$HOME` into the container, your existing `.oh-my-zsh/` and `.zshrc` are automatically available.

To make zsh the default shell on entry:

```bash
chsh -s $(which zsh)   # log out and back in after
```

Or add a fallback in `~/.bashrc`:

```bash
[ -x /usr/bin/zsh ] && exec /usr/bin/zsh
```

---

#### Usage (toolbox)

```bash
toolbox create --image ghcr.io/whilcayangyang/whil-docker-images/fedora-devops-toolbox:latest devops
toolbox enter devops
```

#### Usage (distrobox)

```bash
distrobox create --image ghcr.io/whilcayangyang/whil-docker-images/fedora-devops-toolbox:latest --name devops
distrobox enter devops
```

---

## CI/CD

Images are built and pushed to GHCR automatically on pushes to `main` that modify files under an image subfolder. Manual builds can be triggered via `workflow_dispatch` by specifying the subfolder name (e.g. `vscode-sandbox`).

| Tag | Meaning |
|-----|---------|
| `latest` | tracks `main` |
| `sha-<commit>` | immutable per-commit tag |

---

## Adding a New Image

1. Create a subfolder (e.g. `my-image/`)
2. Add a `Dockerfile` (and optionally `entrypoint.sh`, `docker-compose.yaml`)
3. Push to `main` — the workflow detects changed subfolders and builds automatically

---

## Prerequisites

| Tool | Install |
|------|---------|
| [Podman](https://podman.io/) | `sudo dnf install podman` |
| [podman-compose](https://github.com/containers/podman-compose) | `sudo dnf install podman-compose` |
