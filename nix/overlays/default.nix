final: prev: {
  # Custom packages
  dbpro = final.callPackage ../pkgs/dbpro.nix { };
  llmster = final.callPackage ../pkgs/llmster.nix { };
  lmstudio = final.callPackage ../pkgs/lmstudio.nix { };
  opencode = final.callPackage ../pkgs/opencode.nix { };
  openchamber-web = final.callPackage ../pkgs/openchamber-web { };
  opencode-desktop = final.callPackage ../pkgs/opencode-desktop.nix { };
  openfang = final.callPackage ../pkgs/openfang.nix { };
  swift-toolchain = final.callPackage ../pkgs/swift-toolchain.nix { };
  swift-fhs = final.callPackage ../pkgs/swift-fhs.nix { };
  xtool = final.callPackage ../pkgs/xtool.nix { };

  # Pure Ruby; nixpkgs only lists darwin, but `pod` runs fine on Linux.
  cocoapods = prev.cocoapods.override {
    bundlerApp =
      args:
      prev.bundlerApp (
        args
        // {
          meta = args.meta // {
            platforms = prev.lib.platforms.unix;
          };
        }
      );
  };

  # Upstream OPA tests fail; disable checks.
  open-policy-agent = prev.open-policy-agent.overrideAttrs (_: {
    doCheck = false;
  });
}
