FROM debian:bookworm-slim

ARG CLAUDE_CODE_VERSION=latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    less \
    openssh-client \
    procps \
    ripgrep \
 && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash claude && \
    mkdir -p /workspace /home/claude/.claude && \
    chown -R claude:claude /workspace /home/claude/.claude

USER claude
WORKDIR /workspace

ENV HOME=/home/claude
ENV PATH=/home/claude/.local/bin:${PATH}
ENV CLAUDE_CONFIG_DIR=/home/claude/.claude

RUN curl -fsSL https://claude.ai/install.sh | bash -s ${CLAUDE_CODE_VERSION}

CMD ["sleep", "infinity"]
 
