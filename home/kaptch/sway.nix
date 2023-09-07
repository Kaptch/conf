{ pkgs, lib, config, ... }:
let
  # Initial sway config
  sway-cfg = config.wayland.windowManager.sway.config;
in
{
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    systemdIntegration = true;
    extraSessionCommands = ''
      . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
    '';
    config = {
      terminal = "alacritty";
      menu = "fuzzel";
      modifier = "Mod4";
      bars = [ ];
      startup = [
        # { command = "mako"; }
        { command = "waybar"; }
      ];
      bindkeysToCode = true;
      keybindings =
        let
          screenshot_dir =
            "~/Pictures/Screenshots/$(date +'%Y-%m-%d+%H:%M:%S').png";
        in
          lib.mkOptionDefault {
            "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
            "--locked XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
            "--locked XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +5%";
            "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
            "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
            "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
            "${sway-cfg.modifier}+p" = "exec ${pkgs.wdisplays}/bin/wdisplays";
            "${sway-cfg.modifier}+t" = "exec dbus-send --type=method_call --dest=io.crow_translate.CrowTranslate /io/crow_translate/CrowTranslate/MainWindow io.crow_translate.CrowTranslate.MainWindow.translateSelection";
            "${sway-cfg.modifier}+l" = "exec ${pkgs.swaylock-effects}/bin/swaylock --screenshots --clock --indicator --indicator-radius 100 --indicator-thickness 7 --effect-blur 7x5 --effect-vignette 0.5:0.5 --ring-color bb00cc --key-hl-color 880033 --line-color 00000000 --inside-color 00000088 --separator-color 00000000 --grace 2 --fade-in 0.2";
	          "${sway-cfg.modifier}+Print" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot --notify save screen ${screenshot_dir}";
            "${sway-cfg.modifier}+Shift+Print" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot --notify save area ${screenshot_dir}";
            "${sway-cfg.modifier}+Shift+a" = "exec pkill -9 nwggrid || ${pkgs.nwg-drawer}/bin/nwg-drawer";
            "${sway-cfg.modifier}+x" = "exec emacsclient -c";
          };
    };
    # swaybg_command oguri -c ~/.config/oguri/config
    extraConfig = ''
      set $laptop eDP-1
      set $lock '${pkgs.swaylock-effects}/bin/swaylock --screenshots --clock --indicator --indicator-radius 100 --indicator-thickness 7 --effect-blur 7x5 --effect-vignette 0.5:0.5 --ring-color bb00cc --key-hl-color 880033 --line-color 00000000 --inside-color 00000088 --separator-color 00000000 --grace 2 --fade-in 0.2'
      bindswitch --reload --locked lid:on output $laptop disable
      bindswitch --reload --locked lid:off output $laptop enable
      set $wallpapers_path $HOME/Pictures/wallpapers
      output * bg #000000 solid_color
      output * bg `find $wallpapers_path -type f | shuf -n 1` fill
      default_border none
      # set $opacity 0.9
      # for_window [class=".*"] opacity $opacity
      # for_window [app_id=".*"] opacity $opacity
      for_window [shell=".*"] title_format "%title :: %shell"
      for_window [app_id="firefox"] inhibit_idle fullscreen
      for_window [app_id="Firefox"] inhibit_idle fullscreen
      for_window [app_id="firefox" title="^Picture-in-Picture$"] floating enable, move position 877 450, sticky enable, opacity 1.0
      for_window [app_id="io.crow_translate.CrowTranslate"] floating enable, move position cursor, opacity 0.8
      for_window [window_role="pop-up"] floating enable
      for_window [window_role="bubble"] floating enable
      for_window [window_role="dialog"] floating enable
      for_window [window_type="dialog"] floating enable
      for_window [title="(?:Open|Save) (?:File|Folder|As)"] floating enable, resize set width 1030 height 710
      input type:keyboard {
        xkb_layout us,dk,ru
        xkb_variant qwerty
        xkb_options grp:win_space_toggle,caps:ctrl_modifier
      }
      input type:touchpad {
        dwt enabled
        tap enabled
        middle_emulation enabled
      }
    '';
  };
}
