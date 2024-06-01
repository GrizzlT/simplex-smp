{
  description = "Development shells for `simplex-smp` Rust project";

  outputs = { self, nixpkgs, systems, ... }@inputs: let
    pkgs' = system: import nixpkgs {
      inherit system;
      overlays = [ inputs.rust-overlay.overlays.default ];
    };
    forSystems = f: nixpkgs.lib.genAttrs (import systems) (system: f (pkgs' system));
  in {
    devShells = forSystems (pkgs: let
      mkDevShell = toolchain: pkgs.mkShell {
        shellHook = ''
          export RUST_SRC_PATH=${pkgs.rustPlatform.rustLibSrc}
        '';
        nativeBuildInputs = [ toolchain pkgs.rust-analyzer ];
      };
    in rec {
      default = stable;

      stable = mkDevShell pkgs.rust-bin.stable.latest.default;
      nightly = mkDevShell (pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default));
    });
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    systems.url = "github:nix-systems/default";

    rust-overlay.url = "github:oxalica/rust-overlay";
  };
}
