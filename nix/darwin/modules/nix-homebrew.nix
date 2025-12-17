{ inputs, ... }:

{
  nix-homebrew = {
    enable = true;
    user = "arne";
    enableRosetta = true;

    # Pin taps for reproducibility
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "supabase/homebrew-tap" =  inputs.homebrew-supabase;
      "oven-sh/homebrew-bun" =   inputs.homebrew-bun;
    };

    mutableTaps = false;
    autoMigrate = true;
  };
}
