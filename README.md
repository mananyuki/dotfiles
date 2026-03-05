# dotfiles

Declarative macOS environment using nix-darwin and Home Manager.

## Setup

```shell
# Install Nix
curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install

# Clone
git clone https://github.com/mananyuki/dotfiles.git ~/go/src/github.com/mananyuki/dotfiles
cd ~/go/src/github.com/mananyuki/dotfiles

# Build (validate without applying)
darwin-rebuild build --flake .#work

# Apply
darwin-rebuild switch --flake .#work
```

See [nix/README.md](nix/README.md) for details.
