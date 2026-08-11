# evenhub-simulator-nix

Run [EvenHub Simulator](https://www.npmjs.com/package/@evenrealities/evenhub-simulator) on NixOS.

Currently, only x86_64 Linux is supported.

## Usage

```bash
# Terminal 1 - Vite dev server
nix run dev

# Terminal 2 - Simulator (point it at the dev URL)
nix run github:yvt/evenhub-simulator-nix -- http://localhost:12321
```

The `evenhub-simulator-headless` package is provided for headless testing.
