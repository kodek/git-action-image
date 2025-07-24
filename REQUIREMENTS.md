# Gitea Actions Base Image Requirements

This document outlines the comprehensive tool and dependency requirements for a custom Gitea Actions base image, designed to support all project types across the codebase. The requirements are based on analysis of common tools used in `py-smolagents-test`, `python-microservices-template`, `nix`, and `talos-clusters` projects.

## Core System Requirements

### Base OS
- **Based on existing Act Runner image**: ghcr.io/catthehacker/ubuntu:act-latest
- Essential system utilities: `curl`, `wget`, `unzip`, `tar`, `gzip`

## Programming Languages & Runtimes

### Essential (Universal across all projects)

Latest main (supported) versions.
Environments may bring in older versions if needed, though they aren't strictly supported.

- **Python 3.13** - Primary language for most projects
- **Node.js 24**  - Frontend builds and tooling
- **TypeScript** - Frontend development
- **Go 1.24+** - Infrastructure and tooling
- **CUE v0.13.2+** - Configuration language
- **Bash/Zsh** - Shell scripting

## Package Managers & Dependency Management

### Python Ecosystem
- **uv** - Modern Python package manager (universal across projects)

### Node.js Ecosystem  
- **npm** - Node.js package manager (universal)
- **yarn** - Alternative Node.js package manager

### System Package Managers
- **Nix** - Package manager and environment management
- **apt/apk** - System package manager (depending on base OS)

## Container & Orchestration Tools

### Container Runtime & Building
- **Docker** - Container runtime and building (universal)
- **Docker Buildx** - Multi-platform builds

### Kubernetes Ecosystem
- **kubectl** - Kubernetes CLI (universal)
- **Helm** - Kubernetes package manager
- **Kustomize** - Configuration management

### GitOps & Deployment
- **Flux CD CLI** - GitOps continuous delivery (universal)

## Build & Task Management

### Task Runners
- **Task (go-task)** - Modern task runner (universal)

## Code Quality & Linting

### Python Tools (Universal)
- **ruff** - Python linter and formatter
- **basedpyright** - Python type checker
- **black** - Python formatter (fallback)

### Multi-language Tools
- **pre-commit** - Git hooks management (universal)
- **treefmt** - Universal code formatter
- **ESLint** - JavaScript/TypeScript linting
- **golangci-lint** - Go linter
- **alejandra** - Nix code formatter


## Security & Secrets Management

- **SOPS** - Secrets encryption/decryption
- **age** - Encryption backend

## Development Environment Tools

- **devenv** - Nix-based development environments
- **direnv** - Environment variable management

- **Git** - Version control (universal)
- **GitHub CLI (gh)** - GitHub API interactions
- **OpenSSH** - SSH client

## Data Processing & Utilities

### Text Processing (Universal)
- **jq** - JSON processor
- **yq-go** - YAML/JSON processor  
- **ripgrep (rg)** - Fast text search

## Monitoring & Observability

### Health Checks & Monitoring
- **curl** - HTTP health checks (universal)
- **Health check utilities** - Application monitoring

## Image Optimization Considerations

### Multi-stage Build Strategy

The goal is to minimize the number of layers modified when building on top of the new image.

1. **Base layer**: System dependencies and core runtimes
2. **Package managers**: Common CLI tools used for installing other packages
3. **Common tools**: Common CLI tools used for common tasks
3. **Language layer**: Language-specific tools and packages

### Caching Strategy

- Pre-install all Tier 1 tools for maximum cache hit rate
- Use BuildKit for efficient layer caching
- Separate frequently changing tools into their own layers
- Pre-warm common package caches (uv, npm, Nix store)

This comprehensive base image will provide a consistent, fast-starting environment for all Gitea Actions workflows across the project ecosystem.
