ARG FEDORA_VERSION=44

FROM fedora:${FEDORA_VERSION} AS builder

ENV TF_VERSION="1.15.2"
ENV TFDOCS_VERSION="v0.23.0"
ENV KUBESEAL_VERSION="0.36.6"
ENV FLUX_VERSION="2.8.6"
ENV SOPS_VERSION="3.13.1"

RUN dnf install -y curl unzip tar openssl && dnf clean all

# --- terraform ---
RUN TF_ZIP="terraform_${TF_VERSION}_linux_amd64.zip" \
  && curl -sfL "https://releases.hashicorp.com/terraform/${TF_VERSION}/${TF_ZIP}" -o /tmp/${TF_ZIP} \
  && unzip -o /tmp/${TF_ZIP} -d /usr/local/bin/ > /dev/null \
  && chmod +x /usr/local/bin/terraform \
  && rm -f /tmp/${TF_ZIP}

# --- tflint ---
RUN curl -sfL https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh \
  | bash -s -- -b /usr/local/bin

# --- trivy ---
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
  | sh -s -- -b /usr/local/bin

# --- terraform-docs ---
RUN TFDOCS_TGZ="terraform-docs-${TFDOCS_VERSION}-linux-amd64.tar.gz" \
  && curl -sfL "https://github.com/terraform-docs/terraform-docs/releases/download/${TFDOCS_VERSION}/${TFDOCS_TGZ}" \
  -o /tmp/${TFDOCS_TGZ} \
  && tar -xzf /tmp/${TFDOCS_TGZ} -C /usr/local/bin/ \
  && chmod +x /usr/local/bin/terraform-docs \
  && rm -f /tmp/${TFDOCS_TGZ} /usr/local/bin/LICENSE /usr/local/bin/README.md

# --- talos ---
RUN curl -sL https://talos.dev/install | sh

# --- kubeseal ---
RUN curl -sfOL "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz" \
  && tar -xzf kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz kubeseal \
  && install -m 755 kubeseal /usr/local/bin/kubeseal \
  && rm -f kubeseal kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz

# --- sops ---
RUN curl -sfL "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.amd64" \
  -o /usr/local/bin/sops \
  && chmod +x /usr/local/bin/sops

# --- flux ---
RUN curl -sfL "https://github.com/fluxcd/flux2/releases/download/v${FLUX_VERSION}/flux_${FLUX_VERSION}_linux_amd64.tar.gz" \
  -o /tmp/flux.tar.gz \
  && tar -xzf /tmp/flux.tar.gz -C /usr/local/bin/ flux \
  && chmod +x /usr/local/bin/flux \
  && rm -f /tmp/flux.tar.gz

# --- final image (must be fedora-toolbox for toolbox/distrobox compatibility) ---
FROM registry.fedoraproject.org/fedora-toolbox:${FEDORA_VERSION}

LABEL com.github.containers.toolbox="true"
LABEL org.opencontainers.image.source="https://github.com/whilcayangyang/whil-docker-images"
LABEL org.opencontainers.image.description="Fedora toolbox with DevOps tooling for Silverblue"

COPY --from=builder /usr/local/bin/terraform      /usr/local/bin/terraform
COPY --from=builder /usr/local/bin/tflint         /usr/local/bin/tflint
COPY --from=builder /usr/local/bin/trivy          /usr/local/bin/trivy
COPY --from=builder /usr/local/bin/terraform-docs /usr/local/bin/terraform-docs
COPY --from=builder /usr/local/bin/talosctl       /usr/local/bin/talosctl
COPY --from=builder /usr/local/bin/kubeseal       /usr/local/bin/kubeseal
COPY --from=builder /usr/local/bin/flux           /usr/local/bin/flux
COPY --from=builder /usr/local/bin/sops           /usr/local/bin/sops

RUN dnf install -y \
  kubectl \
  helm \
  k9s \
  ansible \
  nodejs \
  npm \
  hugo \
  go-task \
  git \
  curl \
  jq \
  yq \
  age \
  restic \
  rclone \
  zsh \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  fastfetch \
  python3-pip \
  && dnf clean all
