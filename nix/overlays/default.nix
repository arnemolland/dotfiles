final: _prev: {
  dbpro = final.callPackage ../pkgs/dbpro.nix { };
  opencode = final.callPackage ../pkgs/opencode.nix { };
  opencode-desktop = final.callPackage ../pkgs/opencode-desktop.nix { };
}
