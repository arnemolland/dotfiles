{ ... }:

{
  programs.git = {
    enable = true;
    lfs.enable = true;
    signing.signByDefault = true;
    userName = "Arne Molland";
    userEmail = "arne@molland.sh";
    extraConfig = {
      push.autoSetupRemote = true;
      pull.rebase = true;
      submodule.recurse = true;
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
    };
  };
}
