{ config, pkgs, lib, ... }:
{
  # systemd.user.services.waybar = {
  #   Unit = {
  #     PartOf = lib.mkForce [ "sway-session.target" ];
  #     After = lib.mkForce [ "sway-session.target" ];
  #   };
  #   Service = {
  #     ExecStart = lib.mkForce ''${pkgs.waybar}/bin/waybar -l debug'';
  #     # Environment = "PATH=$PATH:${lib.makeBinPath [ pkgs.procps pkgs.wf-recorder ]}";
  #     # LC_TIME="en_GB.UTF-8"
  #   };
  # };

  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    # package = waybar_patch;
    # systemd.enable = true;
    # systemd.target = "sway-session.target";
    # systemd.target = "hyprland-session.target";
    style = lib.readFile ./dotfiles/waybar.css;
    settings = [{
      height = 40;
      layer = "top";
      position = "top";
      modules-center = [
        # "custom/cal"
        "clock"
      ];
      modules-left = [
        # "wlr/workspaces"
        # "hyprland/language"
        "sway/workspaces"
        "sway/language"
        "sway/mode"
        "custom/mpd1"
        "mpd"
        "custom/mpd2"
        "cava"
        "gamemode"
        # "custom/screen"
        "custom/elinks"
        "custom/neomutt"
        "custom/profanity"
        "custom/irssi"
        "custom/newsboat"
        "custom/recording"
        "custom/mirror"
      ];
      modules-right = [
        "tray"
        "pulseaudio"
        "network"
        "bluetooth"
        "cpu"
        "memory"
        "disk"
        "backlight"
        "temperature"
        "battery"
        "custom/power"
      ];
      cava = {
        method = "pipewire";
        source = "auto";
        bar_delimiter = 0;
        format-icons = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" ];
        bars = 14;
        sample_rate = 44100;
        lower_cutoff_freq = 50;
        higher_cutoff_freq = 10000;
      };
      mpd = {
        tooltip = true;
        tooltip-format = "{artist} - {album} - {title} - Total Time : {totalTime:%M:%S}";
        format = " {elapsedTime:%M:%S}";
        format-disconnected = "⚠";
        format-stopped = "⏹";
        format-paused = "⏸ {elapsedTime:%M:%S}";
        on-click = "${pkgs.alacritty}/bin/alacritty -e ${pkgs.ncmpcpp}/bin/ncmpcpp";
        on-click-right = "${pkgs.mpc-cli}/bin/mpc toggle";
        state-icons = {
          playing = "";
          paused = "";
        };
      };
      "custom/elinks" = {
        tooltip = false;
        tooltip-format = "ELinks";
        format = "";
        on-click = "${pkgs.alacritty}/bin/alacritty -e ${pkgs.elinks}/bin/elinks";
      };
      "custom/neomutt" = {
        tooltip = false;
        tooltip-format = "Neomutt";
        format = "";
        on-click = "${pkgs.alacritty}/bin/alacritty -e ${pkgs.neomutt}/bin/neomutt";
      };
      "custom/profanity" = {
        tooltip = false;
        tooltip-format = "Profanity";
        format = "";
        on-click = "${pkgs.alacritty}/bin/alacritty -e ${pkgs.profanity}/bin/profanity";
      };
      "custom/irssi" = {
        tooltip = false;
        tooltip-format = "Irssi";
        format = "";
        on-click = "${pkgs.alacritty}/bin/alacritty -e ${pkgs.irssi}/bin/irssi";
      };
      "custom/newsboat" = {
        tooltip = false;
        tooltip-format = "Newsboat";
        format = "";
        on-click = "${pkgs.alacritty}/bin/alacritty -e ${pkgs.newsboat}/bin/newsboat";
      };
      "custom/wallet" = {
        tooltip = false;
        format = "";
      };
      "custom/recording" = {
        format = "{}";
        return-type = "json";
        exec = "if [ $(${pkgs.procps}/bin/pidof wf-recorder > /dev/null && echo true) ]; then printf '{\"text\":\"\",\"class\":\"enabled\"}' ; else printf '{\"text\":\"\"}' ; fi";
        on-click = "if [ $(${pkgs.procps}/bin/pidof wf-recorder > /dev/null && echo true) ]; then pkill -9 wf-recorder; else yes | wf-recorder -t --muxer=v4l2 --codec=rawvideo --pixel-format=yuv420p --file=/dev/video0; fi";
        interval = 1;
      };
      "custom/mirror" = {
        format = "{}";
        return-type = "json";
        exec = "if [ $(${pkgs.procps}/bin/pidof wl-mirror > /dev/null && echo true) ]; then printf '{\"text\":\"\",\"class\":\"enabled\"}' ; else printf '{\"text\":\"\"}' ; fi";
        on-click = "if [ $(${pkgs.procps}/bin/pidof wl-mirror > /dev/null && echo true) ]; then pkill -9 wl-mirror; else wl-mirror $(swaymsg -t get_workspaces | jq -r '.[] | select(.focused==true).output'); fi";
        interval = 1;
      };
      "custom/mpd1" = {
        tooltip = false;
        format = "";
        on-click = "${pkgs.mpc-cli}/bin/mpc -q prev && ${pkgs.mpc-cli}/bin/mpc toggle && ${pkgs.mpc-cli}/bin/mpc toggle";
      };
      "custom/mpd2" = {
        tooltip = false;
        format = "";
        on-click = "${pkgs.mpc-cli}/bin/mpc -q next && ${pkgs.mpc-cli}/bin/mpc toggle && ${pkgs.mpc-cli}/bin/mpc toggle";
      };
      "wlr/workspaces" = {
        format = "{icon}";
        on-click = "activate";
      };
      "hyprland/window" = {
        max-length = 200;
        separate-outputs = true;
      };
      "sway/window" = {
        icon = true;
      };
      backlight = {
		    device = "eDP-1";
		    format = "{percent}% {icon}";
		    format-icons = [ "☼" "☀" ];
        tooltip = false;
	    };
      "custom/power" = {
        format = "";
        tooltip = false;
        on-click = "${pkgs.wlogout}/bin/wlogout -p layer-shell";
      };
      bluetooth = {
        on-click = "${pkgs.blueman}/bin/blueman-manager";
        format = "";
        tooltip-format = "{status}: {controller_alias}\t{controller_address}";
  	    tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
  	    tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
      };
      battery = {
        format = "{capacity}% {icon}";
        format-alt = "{time} {icon}";
        format-charging = "{capacity}% ";
        format-icons = [ "" "" "" "" "" ];
        format-plugged = "{capacity}% ";
        states = {
          critical = 10;
          warning = 20;
        };
      };
      "custom/cal" = {
        tooltip = true;
        format = " {}";
        tooltip-format = "<tt>{}</tt>";
        return-type = "json";
        exec = "${pkgs.python3}/bin/python -u ${./dotfiles/cal.py}";
        interval = 60;
        restart-interval = 1;
        on-click = "${pkgs.alacritty}/bin/alacritty --class floating -e ${pkgs.khal}/bin/khal interactive";
      };
      clock = {
        tooltip = true;
        format = "  {:%a %d %b  %I:%M %p}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
        calendar = {
          mode = "year";
          mode-mon-col = 3;
          weeks-pos = "right";
          on-scroll = 1;
          on-click-right = "mode";
          format = {
            months = "<span color='#ffead3'><b>{}</b></span>";
            days = "<span color='#ecc6d9'><b>{}</b></span>";
            weeks = "<span color='#99ffdd'><b>W{}</b></span>";
            weekdays = "<span color='#ffcc66'><b>{}</b></span>";
            today = "<span color='#ff6699'><b><u>{}</u></b></span>";
          };
        };
        on-click = "${pkgs.alacritty}/bin/alacritty --class floating -e ${pkgs.khal}/bin/khal interactive";
        interval = 60;
      };
      cpu = {
        format = "{usage}% ";
        on-click = "${pkgs.alacritty}/bin/alacritty -e ${pkgs.btop}/bin/btop -p 0";
        tooltip = true;
      };
      memory = {
        format = "{}% ";
        on-click = "${pkgs.alacritty}/bin/alacritty -e ${pkgs.btop}/bin/btop -p 1";
      };
      # "custom/screen" = {
      #   format = "⃢";
      #   tooltip = false;
      #   on-click = "${pkgs.wdisplays}/bin/wdisplays";
      # };
      disk = {
        interval = 30;
        format = "{percentage_free}% 🖴";
        path = "/";
        on-click = "${pkgs.alacritty}/bin/alacritty -e ${pkgs.nnn}/bin/nnn";
      };
      network = {
        interval = 1;
        format-disconnected = "⚠";
        format-ethernet = "";
        format-linked = "";
        format-wifi = "";
        tooltip-format-ethernet = "{ifname}: {ipaddr}/{cidr}   up: {bandwidthUpBits} down: {bandwidthDownBits}";
        tooltip-format-linked = "{ifname} (No IP) ";
        tooltip-format-wifi = "{essid} ({signalStrength}%) ";
        on-click = "${pkgs.alacritty}/bin/alacritty -e ${pkgs.networkmanager}/bin/nmtui";
      };
      pulseaudio = {
        tooltip = false;
        format = "{volume}% {icon} {format_source}";
        format-bluetooth = "{volume}% {icon} {format_source}";
        format-bluetooth-muted = " {icon} {format_source}";
        format-icons = {
          car = "";
          default = [ "" "" "" ];
          handsfree = "";
          headphones = "";
          headset = "";
          phone = "";
          portable = "";
        };
        format-muted = " {format_source}";
        format-source = "{volume}% ";
        format-source-muted = "";
        on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
        on-click-right = "${pkgs.helvum}/bin/helvum";
      };
      "sway/mode" = {
        format = " {}";
        max-length = 50;
      };
      temperature = {
        critical-threshold = 80;
        format = "{temperatureC}°C {icon}";
        format-icons = [ "" "" "" ];
        tooltip = false;
      };
      "sway/language" = {
        format = "{short} {variant}";
        on-click = "${pkgs.sway}/bin/swaymsg input type:keyboard xkb_switch_layout next";
      };
      "hyprland/language" = {
        format = "{short} {variant}";
        on-click = "hyprctl switchxkblayout at-translated-set-2-keyboard next";
      };
    }];
  };
}
