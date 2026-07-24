# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Structure

Each image lives in its own subfolder with a `Dockerfile`. CI detects changes to `*/Dockerfile` or `*/entrypoint.sh` and builds only the affected image.

## Building Images Locally

```bash
docker build -t ghcr.io/whilcayangyang/whil-docker-images/<subfolder>:latest <subfolder>/
```

## Version Pinning

Pin versions via `ENV` variables at the top of the builder stage. Tools installed via install scripts (`tflint`, `trivy`, `talosctl`) are intentionally unpinned — leave them that way.

## fedora-devops-toolbox Gotchas

- **Final stage must use `registry.fedoraproject.org/fedora-toolbox:${FEDORA_VERSION}`** as base, not plain `fedora`. The `com.github.containers.toolbox="true"` label is required for toolbox/distrobox compatibility.
- Multi-stage pattern: download/install binaries in the builder stage (`FROM fedora:${FEDORA_VERSION} AS builder`), copy to final toolbox image. This keeps the final image clean.

## vscode-sandbox Gotchas

- K8s StatefulSet requires explicit Linux capabilities (`CHOWN`, `FOWNER`, `DAC_OVERRIDE`, `NET_BIND_SERVICE`, `SETUID`, `SETGID`, `KILL`, `AUDIT_WRITE`) and `runAsUser: 0` — entrypoint.sh fixes PVC ownership at startup and needs these.
- `AUTHORIZED_KEYS` can be injected as a build ARG, runtime env var, or via K8s Secret mounted at `/authorized_keys.d/`.
- `k8s/` manifests are Kustomize templates: `<PLACEHOLDER>` tokens (namespace, app name, image tag, LoadBalancer IP, etc.) must be substituted before `kubectl apply`. `vscode-secret.yaml.tmpl` must be sealed via `kubeseal` into `vscode-sealed.yaml` (referenced by `kustomization.yaml` but intentionally not committed).

## Adding a New Image

Create a subfolder with a `Dockerfile`. Push to `main` — the workflow auto-detects changed subfolders and builds them.

## CI Tags

- `latest` — tracks `main`
- `sha-<commit>` — immutable per-commit
- CI also logs into Docker Hub (`DOCKERHUB_USERNAME`/`DOCKERHUB_TOKEN` secrets) before building — this only avoids anonymous-pull rate limits during `docker/setup-buildx-action`; images are still tagged and pushed to GHCR only.
