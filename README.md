# dotfiles

Declarative macOS environment using nix-darwin and Home Manager.

## Setup

```shell
# Install Nix
curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install

# Clone
ghq get mananyuki/dotfiles

# Build (validate without applying)
darwin-rebuild build --flake .#work

# Apply
darwin-rebuild switch --flake .#work
```

See [nix/README.md](nix/README.md) for details.
