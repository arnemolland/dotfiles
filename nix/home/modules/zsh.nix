{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autocd = true;
    # Keep zsh config under XDG without relying on a relative path (deprecated).
    dotDir = "${config.xdg.configHome}/zsh";

    history = {
      path = "${config.xdg.dataHome}/zsh/history";
      size = 10000;
      save = 10000;
    };

    shellAliases = {
      cat = "bat --paging=never";
      k = "kubectl";
      d = "docker";
      dc = "docker-compose";
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gca = "git commit -a";
      gcm = "git commit -m";
      gco = "git checkout";
      gcb = "git checkout -b";
      gcp = "git cherry-pick";
      gcpa = "git cherry-pick --abort";
      gcpc = "git cherry-pick --continue";
      gd = "git diff";
      gds = "git diff --staged";
      gl = "git log";
      glg = "git log --graph --oneline --decorate --all";
      gp = "git push";
      gpf = "git push --force-with-lease";
      gpl = "git pull";
      gplr = "git pull --rebase";
      gr = "git rebase";
      grc = "git rebase --continue";
      grs = "git rebase --skip";
      grb = "git rebase -i";
      grba = "git rebase --abort";
      ls = "eza --no-user -l";
      lg = "lazygit";
    };

    oh-my-zsh = {
      enable = true;
      theme = "spaceship";
      custom = "${config.xdg.configHome}/zsh/custom";
      plugins = [
        "git"
        "aws"
        "fzf"
        "terraform"
        "ssh-agent"
        "kubectl"
      ];
    };

    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-completions";
        src = pkgs.zsh-completions;
        file = "share/zsh/site-functions/_git";
      }
    ];

    initContent = ''
      if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi
      export PATH="/run/wrappers/bin:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/nix/var/nix/profiles/default/bin:$PATH"

      if [ -f "${config.xdg.configHome}/.dircolors" ]; then
        if command -v gdircolors >/dev/null; then
          eval "$(gdircolors "${config.xdg.configHome}/.dircolors")"
        elif command -v dircolors >/dev/null; then
          eval "$(dircolors "${config.xdg.configHome}/.dircolors")"
        fi
      fi

      eval "$(direnv hook zsh)"
      autoload -Uz compinit; compinit

      ZSH_AUTOSUGGEST_STRATEGY=(history)
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

      export NVM_DIR="${config.xdg.dataHome}/nvm"
      if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
        . "/opt/homebrew/opt/nvm/nvm.sh"
        [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
      fi

      # bun completions
      [ -s "${config.home.homeDirectory}/.bun/_bun" ] && source "${config.home.homeDirectory}/.bun/_bun"
    '';
  };

  home.file.".config/zsh/custom/themes/spaceship.zsh-theme".source =
    "${pkgs.spaceship-prompt}/share/zsh/themes/spaceship.zsh-theme";
}
