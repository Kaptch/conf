{
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "alacritty";
      key_bindings = [
        {
          key = "V";
          mods = "Control|Shift";
          action = "Paste";
        }
        {
          key = "C";
          mods = "Control|Shift";
          action = "Copy";
        }
      ];
      window = {
        decorations = "full";
        title = "Alacritty";
        dynamic_title = true;
        class = {
          instance = "Alacritty";
          general = "Alacritty";
        };
      };
      font = {
        normal = {
          family = "JetBrains Mono";
          style = "regular";
        };
        bold = {
          family = "JetBrains Mono";
          style = "regular";
        };
        italic = {
          family = "JetBrains Mono";
          style = "regular";
        };
        bold_italic = {
          family = "JetBrains Mono";
          style = "regular";
        };
        size = 12.00;
      };
      colors = {
        primary = {
          background = "#1d1f21";
          foreground = "#c5c8c6";
        };
      };
      window.opacity = 0.8;
    };
  };
}
