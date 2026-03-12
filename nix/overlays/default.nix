final: prev: {
  # Custom packages
  dbpro = final.callPackage ../pkgs/dbpro.nix { };
  opencode = final.callPackage ../pkgs/opencode.nix { };
  opencode-desktop = final.callPackage ../pkgs/opencode-desktop.nix { };

  # Upstream OPA tests fail; disable checks.
  open-policy-agent = prev.open-policy-agent.overrideAttrs (_: {
    doCheck = false;
  });
}
