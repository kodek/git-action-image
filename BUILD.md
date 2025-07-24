# Build Instructions

## Prerequisites

- [Nix package manager](https://nixos.org/download.html) with flakes enabled
- Docker (for loading the built image)

## Quick Start

```bash
# Build the Docker image
nix build .#docker

# Load image into Docker
docker load < result

# Run the image
docker run -it gitea-actions-base:latest
```

## Alternative Build Methods

```bash
# Use the convenience script
nix run .#build-docker

# Enter development environment
nix develop
```

## What's Included

- **Languages**: Python 3.13, Node.js 24, Go 1.24+, CUE v0.13.2+
- **Package Managers**: uv, npm, yarn
- **Container Tools**: docker, kubectl, helm, kustomize, flux
- **Build Tools**: go-task
- **Code Quality**: ruff, basedpyright, eslint, golangci-lint, alejandra
- **Security**: sops, age
- **Development**: devenv, direnv, gh, openssh
- **Utilities**: jq, yq-go, ripgrep

## Reproducible Builds

The `flake.lock` file pins all dependencies for reproducible builds across environments.