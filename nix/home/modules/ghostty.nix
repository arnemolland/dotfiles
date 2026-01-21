{ config, ... }:

let
  ghosttyTheme = ''
    # Catppuccin Mocha OLED (derived from iTerm2 Catppuccin Mocha)
    palette = 0=#45475a
    palette = 1=#f38ba8
    palette = 2=#a6e3a1
    palette = 3=#f9e2af
    palette = 4=#89b4fa
    palette = 5=#f5c2e7
    palette = 6=#94e2d5
    palette = 7=#a6adc8
    palette = 8=#585b70
    palette = 9=#f37799
    palette = 10=#89d88b
    palette = 11=#ebd391
    palette = 12=#74a8fc
    palette = 13=#f2aede
    palette = 14=#6bd7ca
    palette = 15=#bac2de
    background = #000000
    foreground = #cdd6f4
    cursor-color = #f5e0dc
    cursor-text = #000000
    selection-background = #585b70
    selection-foreground = #cdd6f4
  '';

  ghosttyConfig = ''
    theme = catppuccin-mocha-oled
    background-opacity = 1.0
    font = Berkeley Mono
    font-bold = Berkeley Mono Bold
    font-italic = Berkeley Mono Oblique
    font-bold-italic = Berkeley Mono Bold Oblique
  '';
in
{
  home.file."${config.xdg.configHome}/ghostty/config".text = ghosttyConfig;
  home.file."${config.xdg.configHome}/ghostty/themes/catppuccin-mocha-oled".text = ghosttyTheme;
}
