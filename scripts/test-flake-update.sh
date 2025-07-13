#!/usr/bin/env bash
# Test script for flake.lock update process
# This script mimics what the GitHub Actions workflow does

set -euo pipefail

echo "🧪 Testing flake.lock update process locally..."

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Not in a git repository"
    exit 1
fi

# Check if nix is available
if ! command -v nix > /dev/null 2>&1; then
    echo "❌ Nix is not installed or not in PATH"
    exit 1
fi

# Save current flake.lock
echo "📄 Backing up current flake.lock..."
cp flake.lock flake.lock.backup

echo "🔄 Updating flake.lock..."
nix flake update

# Check for changes
if diff -q flake.lock.backup flake.lock > /dev/null; then
    echo "✅ No changes in flake.lock - all dependencies are up to date"
    rm flake.lock.backup
    exit 0
fi

echo "📊 Changes detected in flake.lock"
echo "Changed files:"
git diff --name-only flake.lock.backup flake.lock || true

echo "🏗️  Testing Docker image build..."
if timeout 20m nix build .#docker; then
    echo "✅ Docker image built successfully!"
    echo "🐳 Image details:"
    ls -la result
else
    echo "❌ Docker image build failed!"
    echo "🔄 Restoring original flake.lock..."
    mv flake.lock.backup flake.lock
    exit 1
fi

echo ""
echo "✅ Flake update test completed successfully!"
echo "🔄 To revert changes: mv flake.lock.backup flake.lock"
echo "💾 To commit changes: git add flake.lock && git commit -m 'chore: update flake.lock'"

# Keep the backup for manual review
echo "📁 Backup saved as flake.lock.backup for comparison"