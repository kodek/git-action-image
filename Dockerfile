# Gitea Actions Base Image
# This Dockerfile is for reference only - the actual image is built using Nix
# See flake.nix for the complete build configuration

# To build the image, use:
# nix build .#docker
# docker load < result

# The Nix-built image includes:
# - Programming Languages: Python 3.13, Node.js 24, Go 1.24+, CUE v0.13.2+
# - Package Managers: uv, npm, yarn
# - Container Tools: docker, kubectl, helm, kustomize, flux
# - Build Tools: go-task
# - Code Quality: ruff, basedpyright, eslint, golangci-lint, alejandra
# - Security: sops, age
# - Development: devenv, direnv, gh (GitHub CLI), openssh
# - Utilities: jq, yq-go, ripgrep

# For development environment:
# nix develop

# For direct build and load:
# nix run .#build-docker

FROM scratch
LABEL description="This image is built using Nix. See flake.nix for build configuration."
LABEL maintainer="Generated with Nix flake"