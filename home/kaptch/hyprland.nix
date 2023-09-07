{ pkgs, lib, config, ... }:
let
  screenshot_dir = "~/Pictures/Screenshots/$(date +'%Y-%m-%d+%H:%M:%S').png";
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
      # hidpi = false;
    };
    systemdIntegration = true;
    extraConfig = ''
    $mod = SUPER

    monitor = eDP-1,1920x1080@60,0x0,1

    env = _JAVA_AWT_WM_NONREPARENTING,1
    env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
    env = QT_QPA_PLATFORM,wayland
    env = NIXOS_OZONE_WL,1
    env = WLR_NO_HARDWARE_CURSORS,1

    exec-once = ${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh
    exec-once = polkit-kde-authentication-agent-1
    exec-once = ${pkgs.swaybg}/bin/swaybg -o \* -m fill -i $(find $HOME/Pictures/wallpapers -type f | shuf -n 1)
    exec-once = LC_TIME="en_GB.UTF-8" waybar
    exec-once = hyprctl setcursor Bibata-Original-Ice 24

    xwayland {
      force_zero_scaling = true
    }

    misc {
      disable_hyprland_logo = true
    	disable_splash_rendering = true
      # suppress_portal_warnings = 1
      disable_autoreload = true
      # disable dragging animation
      animate_mouse_windowdragging = false
      # enable variable refresh rate (effective depending on hardware)
      vrr = 1
    }

    gestures {
      workspace_swipe = true
      workspace_swipe_forever = true
    }

    input {
      kb_layout = us,dk,ru
      kb_variant = qwerty
      kb_options = grp:win_space_toggle,caps:ctrl_modifier

      follow_mouse = 1

      accel_profile = flat

      touchpad {
        disable_while_typing = true
        tap-to-click = true
        middle_button_emulation = true
      }
    }

    general {
      gaps_in = 2
      gaps_out = 2
      # border_size = 1
      # col.active_border = rgb(0000ff) rgb(e0b0ff) 270deg
      # col.inactive_border = rgb(b7410e) rgb(e6e6fa) 270deg
      # col.group_border_active = rgb(ffc0cb)
      # col.group_border = rgb(7f2980)
      border_size = 1
      col.active_border = rgba(e5b9c6ff) rgba(c293a3ff) 45deg
      col.inactive_border = 0xff382D2E
      no_border_on_floating = false
    }

    decoration {
      rounding = 8

      blur {
        enabled = true
        size = 3
        passes = 3
        # new_optimizations = true
      }

      drop_shadow = true
      shadow_ignore_window = true
      shadow_offset = 0 5
      shadow_range = 50
      shadow_render_power = 3
      col.shadow = rgba(00000099)
    }

    animations {
      enabled = true
      animation = border, 1, 2, default
      animation = fade, 1, 4, default
      animation = windows, 1, 3, default, popin 80%
      animation = workspaces, 1, 2, default, slide
    }

    dwindle {
      # keep floating dimentions while tiling
      pseudotile = true
      preserve_split = true
    }

    # floats
    windowrulev2 = float, class:floating

    # only allow shadows for floating windows
    windowrulev2 = noshadow, floating:0

    # telegram media viewer
    windowrulev2 = float, title:^(Media viewer)$

    # make Firefox PiP window floating and sticky
    windowrulev2 = float, title:^(Picture-in-Picture)$
    windowrulev2 = pin, title:^(Picture-in-Picture)$

    # throw sharing indicators away
    windowrulev2 = workspace special silent, title:^(Firefox — Sharing Indicator)$
    windowrulev2 = workspace special silent, title:^(.*is sharing (your screen|a window)\.)$

    # start spotify tiled in ws9
    windowrulev2 = tile, title:^(Spotify)$
    windowrulev2 = workspace 9 silent, title:^(Spotify)$

    # start Discord/WebCord in ws2
    windowrulev2 = workspace 2, title:^(.*(Disc|WebC)ord.*)$

    # idle inhibit while watching videos
    windowrulev2 = idleinhibit focus, class:^(mpv|.+exe)$
    windowrulev2 = idleinhibit focus, class:^(firefox)$, title:^(.*YouTube.*)$
    windowrulev2 = idleinhibit fullscreen, class:^(firefox)$

    # fix xwayland apps
    windowrulev2 = rounding 0, xwayland:1, floating:1

    # mouse movements
    bindm = $mod, mouse:272, movewindow
    bindm = $mod, mouse:273, resizewindow
    bindm = $mod ALT, mouse:272, resizewindow

    # compositor commands
    bind = $mod SHIFT, E, exec, pkill Hyprland
    bind = $mod SHIFT, W, exec, pkill waybar; (LC_TIME="en_GB.UTF-8" waybar & disown)
    bind = $mod SHIFT, Q, killactive,
    bind = $mod, Q, exec, hyprctl kill
    bind = $mod, F, fullscreen,
    bind = $mod, G, togglegroup,
    bind = $mod SHIFT, N, changegroupactive, f
    bind = $mod SHIFT, P, changegroupactive, b
    bind = $mod, R, togglesplit,
    bind = $mod, T, togglefloating,
    bind = $mod, O, pseudo,
    bind = $mod ALT, ,resizeactive,
    bind = $mod, P, pin,

    # utility
    # launcher
    bindr = $mod SHIFT, A, exec, pkill -9 nwggrid || ${pkgs.nwg-drawer}/bin/nwg-drawer
    # launcher
    bindr = $mod, D, exec, pkill -9 fuzzel; ${pkgs.fuzzel}/bin/fuzzel
    # terminal
    bind = $mod, Return, exec, ${pkgs.alacritty}/bin/alacritty
    # lock screen
    bind = $mod, L, exec, ${pkgs.swaylock-effects}/bin/swaylock --screenshots --clock --indicator --indicator-radius 100 --indicator-thickness 7 --effect-blur 7x5 --effect-vignette 0.5:0.5 --ring-color bb00cc --key-hl-color 880033 --line-color 00000000 --inside-color 00000088 --separator-color 00000000 --grace 2 --fade-in 0.2
    # emacs
    bind = $mod, X, exec, emacsclient -c
    # file manager
    bind = $mod, E, exec, ${pkgs.alacritty}/bin/alacritty -e ${pkgs.nnn}/bin/nnn
    # screenshots
    bind = $mod, Print, exec, ${pkgs.sway-contrib.grimshot}/bin/grimshot --notify save screen ${screenshot_dir}
    bind = $mod SHIFT, Print, exec, ${pkgs.sway-contrib.grimshot}/bin/grimshot --notify save area ${screenshot_dir}
    # mpd
    bind = $mod, M, exec, ${pkgs.alacritty}/bin/alacritty -e ${pkgs.ncmpcpp}/bin/ncmpcpp
    # gamemode
    bind = $mod, F1, exec, hyprland-gamemode-toggle

    # move focus
    bind = $mod, left, movefocus, l
    bind = $mod, right, movefocus, r
    bind = $mod, up, movefocus, u
    bind = $mod, down, movefocus, d

    # window movements
    bind = $mod SHIFT, left, movewindow, l
    bind = $mod SHIFT, right, movewindow, r
    bind = $mod SHIFT, up, movewindow, u
    bind = $mod SHIFT, down, movewindow, d

    # window resize
    bind = $mod, S, submap, resize

    submap = resize
    binde = , right, resizeactive, 10 0
    binde = , left, resizeactive, -10 0
    binde = , up, resizeactive, 0 -10
    binde = , down, resizeactive, 0 10
    bind = , escape, submap, reset
    submap = reset

    # media controls
    bindl = , XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause

    # volume
    bindle = , XF86AudioRaiseVolume, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%
    bindle = , XF86AudioLowerVolume, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%
    bindl = , XF86AudioMute, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle

    # backlight
    bindle = , XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl set +5%
    bindle = , XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 5%-

    # workspaces
    ${builtins.concatStringsSep "\n" (builtins.genList (
        x: let
          ws = let
            c = (x + 1) / 10;
          in
            builtins.toString (x + 1 - (c * 10));
        in ''
          bind = $mod, ${ws}, workspace, ${toString (x + 1)}
          bind = $mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}
        ''
      )
      10)}

    # special workspace
    bind = $mod SHIFT, grave, movetoworkspace, special
    bind = $mod, grave, togglespecialworkspace, eDP-1

    # cycle workspaces
    bind = $mod, bracketleft, workspace, m-1
    bind = $mod, bracketright, workspace, m+1

    bind = $mod CONTROL, period, focusmonitor, +1

    # trigger when the lid is up
    bindl=,switch:off:Lid Switch,exec,hyprctl dispatch dpms on eDP-1
    # trigger when the lid is down
    bindl=,switch:on:Lid Switch,exec,hyprctl dispatch dpms off eDP-1
  '';
  };
}
