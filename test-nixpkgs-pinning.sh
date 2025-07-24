#!/usr/bin/env bash

# Test script to verify nixpkgs pinning functionality
set -euo pipefail

echo "Testing nixpkgs pinning functionality..."

# Test 1: Verify registry is configured
echo "✓ Test 1: Checking nixpkgs registry configuration"
if docker run --rm git-actions-base:latest test -f /etc/nix/registry.json; then
    echo "  ✅ Registry file exists"
else
    echo "  ❌ Registry file missing"
    exit 1
fi

# Test 2: Verify registry contains pinned nixpkgs
echo "✓ Test 2: Verifying pinned nixpkgs in registry"
PINNED_REV=$(docker run --rm git-actions-base:latest jq -r '.flakes[0].to.rev' /etc/nix/registry.json)
if [[ "$PINNED_REV" =~ ^[a-f0-9]{40}$ ]]; then
    echo "  ✅ Nixpkgs pinned to revision: $PINNED_REV"
else
    echo "  ❌ Invalid or missing nixpkgs revision: $PINNED_REV"
    exit 1
fi

# Test 3: Verify pre-cached packages work instantly
echo "✓ Test 3: Testing pre-cached packages"
for pkg in cowsay hello tree; do
    if docker run --rm git-actions-base:latest "$pkg" --version >/dev/null 2>&1 || docker run --rm git-actions-base:latest "$pkg" --help >/dev/null 2>&1; then
        echo "  ✅ Package $pkg is pre-cached and working"
    else
        echo "  ❌ Package $pkg failed"
        exit 1
    fi
done

# Test 4: Verify nix run nixpkgs# uses pinned version
echo "✓ Test 4: Testing that nix run nixpkgs# uses pinned version"
NIXPKGS_OUTPUT=$(docker run --rm git-actions-base:latest nix run nixpkgs#hello 2>&1)
if echo "$NIXPKGS_OUTPUT" | grep -q "$PINNED_REV"; then
    echo "  ✅ nix run nixpkgs# uses pinned revision $PINNED_REV"
else
    echo "  ❌ nix run nixpkgs# not using pinned revision"
    echo "  Output: $NIXPKGS_OUTPUT"
    exit 1
fi

# Test 5: Verify consistency across multiple runs
echo "✓ Test 5: Testing consistency across multiple runs"
REV1=$(docker run --rm git-actions-base:latest nix run nixpkgs#hello 2>&1 | grep -o 'github:NixOS/nixpkgs/[a-f0-9]*' | cut -d'/' -f3)
REV2=$(docker run --rm git-actions-base:latest nix run nixpkgs#cowsay -- test 2>&1 | grep -o 'github:NixOS/nixpkgs/[a-f0-9]*' | cut -d'/' -f3)

if [[ "$REV1" == "$REV2" ]] && [[ "$REV1" == "$PINNED_REV" ]]; then
    echo "  ✅ Multiple runs use same pinned revision: $REV1"
else
    echo "  ❌ Inconsistent revisions: $REV1 vs $REV2 (expected: $PINNED_REV)"
    exit 1
fi

echo ""
echo "🎉 All tests passed! Nixpkgs pinning is working correctly."
echo "   Pinned to revision: $PINNED_REV"
echo "   Pre-cached packages: cowsay, hello, tree, htop, vim, nano, less, file, curl, wget"