{ pkgs, lib, ... }:
{
  services.nix-daemon.enable = true;
  services.emacs = {
    enable = true;
    package = pkgs.emacsMacport;
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  security.pam.enableSudoTouchIdAuth = true;
  system.defaults.dock.autohide = true;
  system.defaults.dock.mru-spaces = false;
  system.defaults.dock.orientation = "left";
  system.defaults.dock.showhidden = true;
  services.skhd.enable = true;
  services.skhd.skhdConfig = lib.readFile ./dotfiles/skhd.conf;
  services.yabai = {
    enable = true;
    enableScriptingAddition = true;
    config = {
      focus_follows_mouse          = "autoraise";
      mouse_follows_focus          = "off";
      window_placement             = "second_child";
      window_opacity               = "off";
      window_opacity_duration      = "0.0";
      window_border                = "on";
      window_border_placement      = "inset";
      window_border_width          = 2;
      window_border_radius         = 3;
      active_window_border_topmost = "off";
      window_topmost               = "on";
      window_shadow                = "float";
      active_window_border_color   = "0xff5c7e81";
      normal_window_border_color   = "0xff505050";
      insert_window_border_color   = "0xffd75f5f";
      active_window_opacity        = "1.0";
      normal_window_opacity        = "1.0";
      split_ratio                  = "0.50";
      auto_balance                 = "on";
      mouse_modifier               = "fn";
      mouse_action1                = "move";
      mouse_action2                = "resize";
      layout                       = "bsp";
      top_padding                  = 10;
      bottom_padding               = 10;
      left_padding                 = 10;
      right_padding                = 10;
      window_gap                   = 10;
    };
    extraConfig = ''
      # rules
      yabai -m rule --add app='System Preferences' manage=off
      # Any other arbitrary config here
    '';
  };
}
