# whil-docker-images

A collection of Docker images built and published to GHCR via GitHub Actions.

## Images

### `vscode-sandbox`

A Debian-based SSH remote development container pre-loaded with infrastructure tooling, designed for use as a [VS Code Remote - SSH](https://code.visualstudio.com/docs/remote/ssh) target.

**Included tools:**

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

**Image:** `ghcr.io/whilcayangyang/whil-docker-images/vscode-sandbox:latest`

#### Docker Compose

```bash
cp vscode-sandbox/.env.example vscode-sandbox/.env
# Edit .env and set your SSH public key
nano vscode-sandbox/.env

docker compose -f vscode-sandbox/docker-compose.yaml up -d
```

Then connect via VS Code Remote - SSH on port `2222`:

```
ssh -p 2222 whil@<host>
```

#### Kubernetes

Requires a cluster with [MetalLB](https://metallb.universe.io/) and a `local-path` StorageClass (e.g. [local-path-provisioner](https://github.com/rancher/local-path-provisioner)).

**1. Create the namespace and secret:**

```bash
kubectl apply -f vscode-sandbox/k8s/namespace.yaml

# Replace placeholder with your actual public key
kubectl apply -f vscode-sandbox/k8s/secret.yaml
```

Edit `vscode-sandbox/k8s/secret.yaml` first — replace `ssh-ed25519 AAAA... user@host` with your public key.

**2. Apply remaining manifests:**

```bash
kubectl apply -f vscode-sandbox/k8s/pvc.yaml
kubectl apply -f vscode-sandbox/k8s/statefulset.yaml
kubectl apply -f vscode-sandbox/k8s/service.yaml
```

**3. Get the assigned IP and connect:**

```bash
kubectl get svc -n vscode-sandbox vscode-sandbox-ssh
# Connect on port 22 to the EXTERNAL-IP
ssh whil@<EXTERNAL-IP>
```

The home directory (`/home/whil`) is backed by a 10Gi persistent volume.

---

### `fedora-devops-toolbox`

A Fedora 44 toolbox image for [Silverblue](https://fedoraproject.org/silverblue/) / [distrobox](https://distrobox.it/) with DevOps tooling pre-installed. Built with a multi-stage Dockerfile to keep the final image lean.

**Included tools:**

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
| terraform | 1.15.2 | binary (releases.hashicorp.com) |
| tflint | latest | binary (install script) |
| trivy | latest | binary (install script) |
| terraform-docs | v0.23.0 | binary |
| talosctl | latest | binary (talos.dev/install) |
| kubeseal | 0.36.6 | binary |
| flux | 2.8.6 | binary |
| sops | 3.13.1 | binary |

**Shell (zsh + Oh My Zsh):**

`zsh`, `zsh-autosuggestions`, and `zsh-syntax-highlighting` are installed in the image. Since toolbox mounts your host `$HOME` into the container, your existing `.oh-my-zsh/` directory and `.zshrc` are automatically available — no extra setup needed inside the toolbox.

To make zsh the default shell on entry, ensure your host login shell is set to zsh:

```bash
# Check current login shell
getent passwd $USER | cut -d: -f7

# Change to zsh if needed (then log out and back in)
chsh -s $(which zsh)
```

Alternatively, add this to `~/.bashrc` as a fallback — toolbox will hand off to zsh automatically:

```bash
[ -x /usr/bin/zsh ] && exec /usr/bin/zsh
```

**Image:** `ghcr.io/whilcayangyang/whil-docker-images/fedora-devops-toolbox:latest`

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

Images are built and pushed to GHCR automatically on pushes to `main` that modify files under an image subfolder. You can also trigger a manual build via `workflow_dispatch` and specifying the subfolder name (e.g. `vscode-sandbox`).

Tags produced per build:
- `latest` — tracks `main`
- `sha-<commit>` — immutable per-commit tag

## Adding a New Image

1. Create a subfolder (e.g. `my-image/`)
2. Add a `Dockerfile` (and optionally `entrypoint.sh`, `docker-compose.yaml`)
3. Push to `main` — the workflow detects changed subfolders and builds them automatically
