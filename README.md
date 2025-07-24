# Git Action Image

Base image for GitHub/Gitea Actions workflows

## Features

### Pinned and Pre-cached Nixpkgs

The Docker image includes a pinned nixpkgs registry to ensure deterministic behavior and reduce GitHub API rate limiting:

- **Deterministic builds**: All containers use the same pinned nixpkgs revision
- **Reduced latency**: Common packages (cowsay, hello, curl, wget, tree, htop, vim, nano, less, file) are pre-cached
- **No GitHub rate limiting**: Containers no longer fetch random nixpkgs revisions from GitHub
- **Integration tested**: Popular packages are verified during image build

When you run `nix run nixpkgs#package`, it will use the pinned nixpkgs version instead of fetching the latest from GitHub.
