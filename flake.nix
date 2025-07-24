{
  description = "Git Actions Base Image - Comprehensive toolset for all project types";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        # Programming Languages & Runtimes
        python = pkgs.python313;
        nodejs = pkgs.nodejs_24;
        go = pkgs.go_1_24;
        cue = pkgs.cue;

        # Core system utilities - use meta-packages and environment setup
        systemUtils = with pkgs; [
          # Essential system packages
          coreutils # ls, cat, cp, mv, mkdir, etc.
          util-linux # mount, umount, lsblk, etc.
          findutils # find, xargs
          gnugrep # grep
          gnused # sed
          gawk # awk

          # Network and compression
          curl
          wget
          unzip
          gnutar
          gzip

          # Shells and version control
          bash
          zsh
          git
        ];

        # Package managers
        packageManagers = with pkgs; [
          uv # Python package manager
          yarn # Node.js package manager
        ];

        # Container & Orchestration Tools
        containerTools = with pkgs; [
          docker
          docker-buildx
          kubectl
          kubernetes-helm
          kustomize
          fluxcd # GitOps continuous delivery
        ];

        # Build & Task Management
        buildTools = with pkgs; [
          go-task # Modern task runner
        ];

        # Code Quality & Linting - Python
        pythonLinting = with pkgs; [
          ruff
          basedpyright
        ];

        # Code Quality & Linting - Multi-language
        lintingTools = with pkgs; [
          treefmt
          nodePackages.eslint
          golangci-lint
          alejandra # Nix formatter
        ];

        # Security & Secrets Management
        securityTools = with pkgs; [
          sops
          age
        ];

        # Development Environment Tools
        devTools = with pkgs; [
          nix # Nix package manager for flakes and package management
          direnv
          gh # GitHub CLI
        ];

        # Data Processing & Utilities
        dataTools = with pkgs; [
          jq
          yq-go
          ripgrep
        ];

        # All tools combined
        allTools =
          systemUtils
          ++ packageManagers
          ++ containerTools
          ++ buildTools
          ++ pythonLinting
          ++ lintingTools
          ++ securityTools
          ++ devTools
          ++ dataTools
          ++ [
            python
            nodejs
            go
            cue
          ];

        # Docker image using Nix best practices
        dockerImage = pkgs.dockerTools.buildLayeredImage {
          name = "git-actions-base";
          tag = "latest";

          contents =
            allTools
            ++ (with pkgs.dockerTools; [
              usrBinEnv # Provides /usr/bin/env
              binSh # Provides /bin/sh
              caCertificates # SSL certificates
              fakeNss # /etc/passwd and /etc/group
            ]);

          config = {
            Env = [
              # Properly construct PATH from all included packages
              "PATH=${pkgs.lib.makeBinPath allTools}"
              "PYTHONPATH=${python}/lib/python3.13/site-packages"
              "NODE_PATH=${nodejs}/lib/node_modules"
              # Enable Nix flakes functionality
              "NIX_CONFIG=experimental-features = nix-command flakes"
            ];

            WorkingDir = "/workspace";

            Cmd = ["${pkgs.bash}/bin/bash"];
          };

          maxLayers = 100; # Optimize for layer caching
        };
      in {
        # Docker image output
        packages = {
          default = dockerImage;
          docker = dockerImage;
        };

        # Apps for easy access
        apps = {
          # Build docker image
          build-docker = {
            type = "app";
            program = toString (pkgs.writeShellScript "build-docker" ''
              echo "Building Docker image..."
              nix build .#docker
              docker load < result
              echo "Docker image loaded successfully!"
              echo "Run with: docker run -it git-actions-base:latest"
            '');
          };
        };
      }
    );
}
