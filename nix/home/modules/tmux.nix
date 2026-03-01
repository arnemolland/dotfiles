_:

{
  programs.tmux = {
    enable = true;
    mouse = true;
    terminal = "screen-256color";
    extraConfig = ''
      set -g status-bg black
      set -g status-fg white

      # Prefix + a: open AI chat popup (uses ai-chat helper)
      bind-key a display-popup -E -w 90% -h 85% "ai-chat"
    '';
  };
}
