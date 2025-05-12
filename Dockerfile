FROM docker:latest

# Install Node.js 20.x and npm
RUN apk add --update --no-cache \
    nodejs \
    npm \
    bash \
    curl \
    && node --version \
    && npm --version

# Set environment variables
ENV NODE_VERSION=20

# Add healthcheck to verify the installation
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD node --version || exit 1

# Set default command to keep container running
CMD ["node", "-e", "console.log('Node.js is ready'); setInterval(() => {}, 3600000);"]
