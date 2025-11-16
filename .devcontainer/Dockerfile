FROM node:20-bookworm

# Install pnpm globally
RUN npm install -g pnpm

# Install additional tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Keep container running
CMD ["sleep", "infinity"]
