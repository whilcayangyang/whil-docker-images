#!/usr/bin/env bash
# Installs/updates the pinned DevOps CLI tools from this directory's Dockerfile
# directly inside a running toolbox container, without rebuilding the image.
#
# Usage: sudo ./install-devops-tools.sh
set -euo pipefail
trap 'echo "FAILED at line $LINENO" >&2' ERR

if [[ $EUID -ne 0 ]]; then
  echo "Run as root inside the toolbox (sudo $0)" >&2
  exit 1
fi

TF_VERSION="1.16.4"
TFDOCS_VERSION="v0.24.0"
KUBESEAL_VERSION="0.40.0"
FLUX_VERSION="2.9.5"
SOPS_VERSION="3.13.3"
TALOS_VERSION="1.14.1"
HUGO_VERSION="0.166.0"

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"; echo "FAILED at line $LINENO" >&2' ERR
cd "$WORKDIR"

echo "--- terraform ${TF_VERSION} ---"
TF_ZIP="terraform_${TF_VERSION}_linux_amd64.zip"
curl -sfL "https://releases.hashicorp.com/terraform/${TF_VERSION}/${TF_ZIP}" -o "${TF_ZIP}"
unzip -o "${TF_ZIP}" -d /usr/local/bin/ > /dev/null
chmod +x /usr/local/bin/terraform

echo "--- tflint (latest) ---"
curl -sfL https://github.com/terraform-linters/tflint/releases/latest/download/tflint_linux_amd64.zip \
  -o tflint.zip
unzip -o tflint.zip -d /usr/local/bin/ > /dev/null
chmod +x /usr/local/bin/tflint

echo "--- trivy (latest) ---"
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
  | sh -s -- -b /usr/local/bin

echo "--- terraform-docs ${TFDOCS_VERSION} ---"
TFDOCS_TGZ="terraform-docs-${TFDOCS_VERSION}-linux-amd64.tar.gz"
curl -sfL "https://github.com/terraform-docs/terraform-docs/releases/download/${TFDOCS_VERSION}/${TFDOCS_TGZ}" \
  -o "${TFDOCS_TGZ}"
tar -xzf "${TFDOCS_TGZ}" -C /usr/local/bin/
chmod +x /usr/local/bin/terraform-docs
rm -f /usr/local/bin/LICENSE /usr/local/bin/README.md

echo "--- hugo ${HUGO_VERSION} ---"
HUGO_TGZ="hugo_${HUGO_VERSION}_linux-amd64.tar.gz"
curl -sfL "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_TGZ}" \
  -o "${HUGO_TGZ}"
tar -xzf "${HUGO_TGZ}" -C /usr/local/bin/ hugo
chmod +x /usr/local/bin/hugo

echo "--- talosctl ${TALOS_VERSION} ---"
curl -sfL "https://github.com/siderolabs/talos/releases/download/v${TALOS_VERSION}/talosctl-linux-amd64" \
  -o /usr/local/bin/talosctl
chmod +x /usr/local/bin/talosctl

echo "--- kubeseal ${KUBESEAL_VERSION} ---"
curl -sfOL "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz"
tar -xzf "kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz" kubeseal
install -m 755 kubeseal /usr/local/bin/kubeseal

echo "--- sops ${SOPS_VERSION} ---"
curl -sfL "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.amd64" \
  -o /usr/local/bin/sops
chmod +x /usr/local/bin/sops

echo "--- flux ${FLUX_VERSION} ---"
curl -sfL "https://github.com/fluxcd/flux2/releases/download/v${FLUX_VERSION}/flux_${FLUX_VERSION}_linux_amd64.tar.gz" \
  -o flux.tar.gz
tar -xzf flux.tar.gz -C /usr/local/bin/ flux
chmod +x /usr/local/bin/flux

cd /
rm -rf "$WORKDIR"
trap - ERR

echo "Done. Installed versions:"
terraform version | head -1
tflint --version
trivy --version | head -1
terraform-docs --version
hugo version
talosctl version --client
kubeseal --version
sops --version
flux version --client
