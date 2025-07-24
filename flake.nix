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
          coreutils     # ls, cat, cp, mv, mkdir, etc.
          util-linux    # mount, umount, lsblk, etc.
          findutils     # find, xargs
          gnugrep       # grep
          gnused        # sed
          gawk          # awk
          
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

        # Get the current nixpkgs revision for pinning
        nixpkgsRev = nixpkgs.rev or "unstable";

        # Common packages pre-cached during image build
        commonPackages = with pkgs; [
          cowsay    # For testing
          hello     # Classic test package
          curl      # Network requests
          wget      # Downloads
          tree      # Directory listing
          htop      # Process monitoring
          vim       # Text editor
          nano      # Simple text editor
          less      # Pager
          file      # File type detection
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
          ++ commonPackages
          ++ [
            python
            nodejs
            go
            cue
          ];

        # Create a script to set up the nixpkgs registry
        nixpkgsRegistrySetup = pkgs.writeTextDir "etc/nix/registry.json" (builtins.toJSON {
          version = 2;
          flakes = [
            {
              from = {
                type = "indirect";
                id = "nixpkgs";
              };
              to = {
                type = "github";
                owner = "NixOS";
                repo = "nixpkgs";
                rev = nixpkgsRev;
              };
            }
          ];
        });

        # Create Nix configuration file
        nixConfig = pkgs.writeTextDir "etc/nix/nix.conf" ''
          experimental-features = nix-command flakes
          auto-optimise-store = true
          warn-dirty = false
          trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
        '';

        # Docker image using Nix best practices
        dockerImage = pkgs.dockerTools.buildLayeredImage {
          name = "git-actions-base";
          tag = "latest";

          contents = allTools ++ (with pkgs.dockerTools; [
            usrBinEnv        # Provides /usr/bin/env
            binSh            # Provides /bin/sh
            caCertificates   # SSL certificates
            fakeNss          # /etc/passwd and /etc/group
            nixpkgsRegistrySetup  # Pre-configured nixpkgs registry
            nixConfig        # Nix configuration
          ]);

          config = {
            Env = [
              # Properly construct PATH from all included packages
              "PATH=${pkgs.lib.makeBinPath allTools}"
              "PYTHONPATH=${python}/lib/python3.13/site-packages"
              "NODE_PATH=${nodejs}/lib/node_modules"
              # Enable Nix flakes functionality with registry support
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
