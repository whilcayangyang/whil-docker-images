# whil-docker-images

[![CI](https://github.com/whilcayangyang/whil-docker-images/actions/workflows/docker-build.yaml/badge.svg)](https://github.com/whilcayangyang/whil-docker-images/actions/workflows/docker-build.yaml)
[![GHCR](https://img.shields.io/badge/registry-ghcr.io-blue?logo=github)](https://github.com/whilcayangyang?tab=packages)
[![License: GPL v3](https://img.shields.io/badge/license-GPLv3-blue.svg)](LICENSE)

A collection of container images built and published to GHCR via GitHub Actions.

---

## Images

### `vscode-sandbox`

[![ghcr: vscode-sandbox](https://img.shields.io/badge/ghcr.io-vscode--sandbox-blue?logo=docker&logoColor=white)](https://github.com/whilcayangyang/whil-docker-images/pkgs/container/whil-docker-images%2Fvscode-sandbox)

A Debian-based SSH remote development container pre-loaded with infrastructure tooling, designed for use as a [VS Code Remote - SSH](https://code.visualstudio.com/docs/remote/ssh) target.

```
ghcr.io/whilcayangyang/whil-docker-images/vscode-sandbox:latest
```

<details>
<summary>Included tools</summary>

| Tool | Version |
|------|---------|
| Terraform | 1.15.2 |
| TFLint | latest |
| Trivy | latest |
| terraform-docs | v0.23.0 |
| Hugo | 0.161.1 |
| Python 3 | system |
| Node.js / npm | system |
| Git | system |

</details>

---

### `fedora-devops-toolbox`

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
| git, curl, jq, yq | latest | Fedora repo |
| Node.js / npm | latest | Fedora repo |
| Python 3 / pip | latest | Fedora repo |
| zsh + plugins | latest | Fedora repo |
| fastfetch | latest | Fedora repo |
| terraform | 1.15.2 | binary |
| tflint | latest | binary |
| trivy | latest | binary |
| terraform-docs | v0.23.0 | binary |
| talosctl | latest | binary |

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

## Usage

### `vscode-sandbox`

#### Local build

```bash
podman build -t localhost/vscode-sandbox:local vscode-sandbox/
```

#### Podman Compose

```bash
cp vscode-sandbox/.env.example vscode-sandbox/.env
nano vscode-sandbox/.env          # set AUTHORIZED_KEYS to your SSH public key

podman compose -f vscode-sandbox/docker-compose.yaml up -d
```

Connect via VS Code Remote - SSH:

```bash
ssh -p 2222 whil@<host>
```

#### Kubernetes

Requires a cluster with [MetalLB](https://metallb.universe.io/) and a `local-path` StorageClass (e.g. [local-path-provisioner](https://github.com/rancher/local-path-provisioner)).

```bash
# 1. Namespace + secret (edit secret.yaml first — replace the placeholder public key)
kubectl apply -f vscode-sandbox/k8s/namespace.yaml
kubectl apply -f vscode-sandbox/k8s/secret.yaml

# 2. Storage, workload, service
kubectl apply -f vscode-sandbox/k8s/pvc.yaml
kubectl apply -f vscode-sandbox/k8s/statefulset.yaml
kubectl apply -f vscode-sandbox/k8s/service.yaml

# 3. Get the assigned IP and connect
kubectl get svc -n vscode-sandbox vscode-sandbox-ssh
ssh whil@<EXTERNAL-IP>
```

> The home directory (`/home/whil`) is backed by a 10Gi persistent volume.

### `fedora-devops-toolbox`

#### toolbox

```bash
toolbox create --image ghcr.io/whilcayangyang/whil-docker-images/fedora-devops-toolbox:latest devops
toolbox enter devops
```

#### distrobox

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
