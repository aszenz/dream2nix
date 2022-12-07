{
  inputs = {
    dream2nix.url = "path:../..";
    src.url = "github:yusdacra/linemd/v0.4.0";
    src.flake = false;
  };

  outputs = {
    self,
    dream2nix,
    src,
  } @ inp:
    (dream2nix.lib.makeFlakeOutputs {
      systems = ["x86_64-linux"];
      config.projectRoot = ./.;
      config.modules = [
        (builtins.toFile "cargo-toml-new.nix" ''
          {
            translators.cargo-toml-new = {
              imports = [(attrs: import "${inp.dream2nix}/src/subsystems/rust/translators/cargo-toml" attrs.framework)];
              name = "cargo-toml-new";
              subsystem = "rust";
            };
          }
        '')
        (builtins.toFile "brp-new.nix" ''
          {
            builders.brp-new = {
              imports = [(attrs: import "${inp.dream2nix}/src/subsystems/rust/builders/build-rust-package" attrs.framework)];
              name = "brp-new";
              subsystem = "rust";
            };
          }
        '')
        (builtins.toFile "cargo-new.nix" ''
          {
            discoverers.cargo-new = {
              imports = [(attrs: import "${inp.dream2nix}/src/subsystems/rust/discoverers/cargo" attrs.framework)];
              name = "cargo-new";
              subsystem = "rust";
            };
          }
        '')
        (builtins.toFile "crates-io-new.nix" ''
          {config, ...}: {
            fetchers.crates-io = config.lib.mkForce {
              imports = [(attrs: import "${inp.dream2nix}/src/fetchers/crates-io" attrs.framework)];
            };
          }
        '')
      ];
      source = src;
      projects.linemd = {
        name = "linemd";
        subsystem = "rust";
        translator = "cargo-toml-new";
        builder = "brp-new";
      };
    })
    // {
      # checks.x86_64-linux.linemd = self.packages.x86_64-linux.linemd;
    };
}
