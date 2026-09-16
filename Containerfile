FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
build-essential \
    curl \
    git \
    jq \
    devscripts \
    libvirt-dev \
    libpcap-dev \
    libhivex-dev \
    libhivex-bin \
    zfsutils-linux \
    wireguard \
    imagemagick \
    tesseract-ocr \
    protobuf-compiler \
    vim \
    wget \
    ntfs-3g \
    unzip \
    sudo \
    debootstrap \
    libsystemd-dev \
    libx11-dev \
    libudev-dev \
    xxhash \
    rsync \
    gcc-aarch64-linux-gnu \
    gcc-mingw-w64-x86-64 \
    bubblewrap \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Go
RUN curl -fsSL https://go.dev/dl/go1.27.1.linux-amd64.tar.gz | tar -C /usr/local -xz
ENV PATH="/usr/local/go/bin:${PATH}"

# Install GoReleaser (to /usr/local/bin so it's available to all users)
ENV GOBIN=/usr/local/bin
RUN go install github.com/goreleaser/goreleaser/v2@latest
ENV GOBIN=

RUN wget https://github.com/bufbuild/buf/releases/download/v1.70.0/buf-Linux-x86_64.tar.gz && \
    tar -C /usr/local -xzf buf-Linux-x86_64.tar.gz && \
    rm buf-Linux-x86_64.tar.gz

# Install Python 3
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Install gh (GitHub CLI)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && apt-get install -y --no-install-recommends gh && \
    rm -rf /var/lib/apt/lists/*

# Install jira-cli
RUN curl -fsSL https://github.com/ankitpokhrel/jira-cli/releases/download/v1.7.0/jira_1.7.0_linux_x86_64.tar.gz \
    | tar -xz -C /usr/local/bin --strip-components=2 jira_1.7.0_linux_x86_64/bin/jira

# Run as non-root user matching host UID/GID (overridable at runtime)
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -f -g ${GROUP_ID} claude && \
    useradd -m -u ${USER_ID} -g claude -o claude && \
    echo "claude ALL=(ALL) NOPASSWD:ALL\ncodex ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/claude

USER claude
ENV HOME=/home/claude
ENV GOPATH=/home/claude/go
ENV PATH="/home/claude/go/bin:${PATH}"

# Install Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash
# Install Codex
RUN curl -fsSL https://chatgpt.com/codex/install.sh | bash
ENV PATH="/home/claude/.claude/bin:/home/claude/.local/bin:${PATH}"
ENV TERM=xterm-256color


COPY --chown=claude:claude entrypoint.sh /home/claude/entrypoint.sh

ENTRYPOINT ["/home/claude/entrypoint.sh"]
