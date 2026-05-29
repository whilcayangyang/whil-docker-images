FROM debian:trixie-slim AS builder

ENV TF_VERSION="1.15.2"
ENV TFDOCS_VERSION="v0.23.0"
ENV HUGO_VERSION="0.161.1"

RUN apt update && \
    apt install -y --no-install-recommends curl unzip tar ca-certificates && \
    apt clean && rm -rf /var/lib/apt/lists/*

RUN TF_ZIP="terraform_${TF_VERSION}_linux_amd64.zip" && \
    curl -sfL "https://releases.hashicorp.com/terraform/${TF_VERSION}/${TF_ZIP}" -o /tmp/${TF_ZIP} && \
    unzip -o /tmp/${TF_ZIP} -d /usr/local/bin/ > /dev/null && \
    chmod +x /usr/local/bin/terraform && \
    rm -f /tmp/${TF_ZIP}

RUN curl -sfL https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh \
    | bash -s -- -b /usr/local/bin

RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
    | sh -s -- -b /usr/local/bin

RUN TFDOCS_TGZ="terraform-docs-${TFDOCS_VERSION}-linux-amd64.tar.gz" && \
    curl -sfL "https://github.com/terraform-docs/terraform-docs/releases/download/${TFDOCS_VERSION}/${TFDOCS_TGZ}" \
    -o /tmp/${TFDOCS_TGZ} && \
    tar -xzf /tmp/${TFDOCS_TGZ} -C /usr/local/bin/ && \
    chmod +x /usr/local/bin/terraform-docs && \
    rm -f /tmp/${TFDOCS_TGZ} /usr/local/bin/LICENSE /usr/local/bin/README.md

RUN HUGO_TGZ="hugo_${HUGO_VERSION}_linux-amd64.tar.gz" && \
    curl -sfL "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_TGZ}" \
    -o /tmp/${HUGO_TGZ} && \
    tar -xzf /tmp/${HUGO_TGZ} -C /usr/local/bin/ hugo && \
    chmod +x /usr/local/bin/hugo && \
    rm -f /tmp/${HUGO_TGZ}

# --- final image ---
FROM debian:trixie-slim

LABEL org.opencontainers.image.source="https://github.com/whilcayangyang/whil-docker-images"
LABEL org.opencontainers.image.description="VSCode sandbox with Terraform, TFLint, Trivy, terraform-docs, Hugo"

ARG USERNAME=whil
ARG UID=1000
ARG GID=1000
ARG AUTHORIZED_KEYS=""

RUN echo 'path-exclude=/usr/share/doc/*\npath-exclude=/usr/share/man/*\npath-exclude=/usr/share/info/*\npath-exclude=/usr/share/locale/??/*\npath-exclude=/usr/share/locale/??_??/*' \
    > /etc/dpkg/dpkg.cfg.d/no-docs

COPY --from=builder /usr/local/bin/terraform      /usr/local/bin/terraform
COPY --from=builder /usr/local/bin/tflint         /usr/local/bin/tflint
COPY --from=builder /usr/local/bin/trivy          /usr/local/bin/trivy
COPY --from=builder /usr/local/bin/terraform-docs /usr/local/bin/terraform-docs
COPY --from=builder /usr/local/bin/hugo           /usr/local/bin/hugo

RUN apt update && \
    apt install -y --no-install-recommends \
    sudo \
    openssh-server \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    ca-certificates \
    git \
    curl && \
    apt clean && \
    rm -rf \
    /var/lib/apt/lists/* \
    /usr/share/doc \
    /usr/share/man \
    /usr/share/info \
    /usr/share/locale/?? \
    /usr/share/locale/??_?? \
    /root/.cache && \
    rm -f /etc/ssh/ssh_host_*

RUN groupadd --gid ${GID} ${USERNAME} && \
    useradd --uid ${UID} --gid ${GID} --shell /bin/bash --create-home ${USERNAME} && \
    passwd -d ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME}

RUN mkdir -p /var/run/sshd && \
    sed -i \
    -e 's/^#\?PermitRootLogin.*/PermitRootLogin no/' \
    -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' \
    -e 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' \
    -e 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' \
    -e 's/^#\?UsePAM.*/UsePAM no/' \
    /etc/ssh/sshd_config && \
    echo "AuthorizedKeysFile .ssh/authorized_keys" >> /etc/ssh/sshd_config

RUN mkdir -p /home/${USERNAME}/.ssh && \
    chmod 700 /home/${USERNAME}/.ssh && \
    if [ -n "${AUTHORIZED_KEYS}" ]; then \
    echo "${AUTHORIZED_KEYS}" > /home/${USERNAME}/.ssh/authorized_keys; \
    else \
    touch /home/${USERNAME}/.ssh/authorized_keys; \
    fi && \
    chmod 600 /home/${USERNAME}/.ssh/authorized_keys && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.ssh

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
