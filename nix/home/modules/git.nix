{ ... }:

{
  programs.git = {
    enable = true;
    lfs.enable = true;
    signing.signByDefault = true;
    settings = {
      user = {
        name = "Arne Molland";
        email = "arne@molland.sh";
      };
      push.autoSetupRemote = true;
      pull.rebase = true;
      submodule.recurse = true;
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
    };
  };
}
