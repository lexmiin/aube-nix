# aube-nix

Nix flake for [aube](https://github.com/jdx/aube), packaged from upstream release binaries.

## Usage

Add the flake input:

```nix
inputs.aube-nix.url = "github:lexmiin/aube-nix";
inputs.aube-nix.inputs.nixpkgs.follows = "nixpkgs";
```

Then add the overlay:

```nix
inputs.aube-nix.overlays.default
```

Install `pkgs.aube` as usual.

You can also run it directly:

```sh
nix run github:lexmiin/aube-nix -- --version
```

## Updating

The package is updated by `scripts/update.sh`:

```sh
scripts/update.sh
scripts/update.sh --version 1.25.1
```

The scheduled GitHub workflow checks the latest upstream release and opens a pull request when the package changes.
