FROM ghcr.io/quarto-dev/quarto

COPY ops/apt.txt /ops/apt.txt

RUN set -e; \
    if grep -qw terraform /ops/apt.txt; then \
      DEBIAN_FRONTEND=noninteractive apt-get update && \
      apt-get install -y --no-install-recommends curl gnupg ca-certificates lsb-release && \
      curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
      echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
        > /etc/apt/sources.list.d/hashicorp.list; \
    fi; \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
    xargs -r -a /ops/apt.txt apt-get install -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get purge -y --auto-remove nodejs npm libnode-dev || true && \
    rm -rf /var/lib/apt/lists/*

COPY ops/node.version /ops/node.version

RUN NODE_MAJOR="$(cat /ops/node.version)" && \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates gnupg && \
    curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | bash - && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

COPY ops/pnpm.version /ops/pnpm.version

ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0

RUN corepack enable && \
    corepack prepare "pnpm@$(cat /ops/pnpm.version)" --activate

ENV PNPM_HOME=/usr/local/pnpm PATH="/usr/local/pnpm:${PATH}"

COPY ops/pnpm-global.txt /ops/pnpm-global.txt

RUN if [ -s /ops/pnpm-global.txt ]; \
    then \
      xargs -r -a /ops/pnpm-global.txt pnpm add -g; \
    fi

WORKDIR /workspace
