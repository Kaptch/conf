{ pkgs, config, lib, ... }:
{
  services.udiskie = {
    enable = true;
    tray = "always";
  };

  services.poweralertd = {
    enable = true;
  };

  services.syncthing = {
    enable = true;
  };

  # programs.eww = {
  #   enable = true;
  #   package = pkgs.eww-wayland;
  #   configDir = ./dotfiles/eww;
  # };

  programs.ncmpcpp = {
    enable = true;
  };

  programs.newsboat = {
    enable = true;
    browser = "${pkgs.elinks}/bin/elinks";
    queries = {
    };
    urls = [
      {
        tags = [
          "Logic"
          "CS"
        ];
        url = "https://semantic-domain.blogspot.com/feeds/posts/default";
      }
      {
        tags = [
          "Logic"
          "CS"
        ];
        url = "https://golem.ph.utexas.edu/category/atom10.xml";
      }
      {
        tags = [
          "Logic"
          "CS"
        ];
        url = "http://siek.blogspot.com/feeds/posts/default";
      }
      {
        tags = [
          "Logic"
          "CS"
        ];
        url = "https://bentnib.org/posts.rss.xml";
      }
      {
        tags = [
          "News"
          "CS"
        ];
        url = "https://news.ycombinator.com/rss";
      }
      {
        tags = [
          "Hosting"
          "FlokiNet"
        ];
        url = "https://blog.flokinet.is/feed/";
      }
      {
        tags = [
          "FSF"
        ];
        url = "https://www.fsf.org/static/fsforg/rss/news.xml";
      }
      {
        tags = [
          "FSF"
        ];
        url = "https://www.fsf.org/static/fsforg/rss/blogs.xml";
      }
      {
        tags = [
          "FSF"
        ];
        url = "https://fsfe.org/news/news.en.rss";
      }
      {
        tags = [
          "News"
        ];
        url = "https://feeds.a.dj.com/rss/RSSWorldNews.xml";
      }
      {
        tags = [
          "News"
        ];
        url = "http://feeds.bbci.co.uk/news/world/rss.xml";
      }
      {
        tags = [
          "News"
        ];
        url = "https://rss.nytimes.com/services/xml/rss/nyt/World.xml";
      }
      {
        tags = [
          "News"
        ];
        url = "https://rsshub.app/apnews/topics/apf-topnews";
      }
      {
        tags = [
          "News"
        ];
        url = "https://rsshub.app/apnews/topics/world-news";
      }
      {
        tags = [
          "News"
        ];
        url = "https://rsshub.app/apnews/topics/politics";
      }
    ];
  };

  programs.irssi = {
    enable = true;
    networks = {
      liberachat = {
        nick = "kaptch";
        server = {
          address = "irc.libera.chat";
          port = 6697;
          autoConnect = true;
        };
        channels = {
          nixos.autoJoin = true;
          rust.autoJoin = true;
          ocaml.autoJoin = true;
          haskell.autoJoin = true;
          bash.autoJoin = true;
          emacs.autoJoin = true;
          coq.autoJoin = true;
          latex.autoJoin = true;
          org-mode.autoJoin = true;
          typetheory.autoJoin = true;
        };
      };
    };
  };

  programs.ssh = {
    enable = true;
    forwardAgent = true;
    extraConfig = ''
    Host gpgtunnel
        HostName localhost
        StreamLocalBindUnlink yes
        Port 10022
        User kaptch
        RemoteForward /run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent.extra
  '';
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryFlavor = "gtk2";
    enableExtraSocket = true;
    extraConfig = ''
      allow-emacs-pinentry
    '';
  };

  # services.imapnotify.enable = true;

  services.gnome-keyring.enable = true;

  services.swayidle = {
    enable = true;
    extraArgs = [ "-d" ];
    systemdTarget = "hyprland-session.target";
    timeouts = [
      { timeout = 2400; command = "hyprctl dispatch dpms off"; resumeCommand = "hyprctl dispatch dpms on"; }
      # { timeout = 2400; command = "swaymsg 'output * dpms off'"; resumeCommand = "swaymsg 'output * dpms on'"; }
      { timeout = 3600; command = "${pkgs.elogind}/bin/loginctl hybrid-sleep"; }
    ];
    events = [
      { event = "before-sleep"; command = "${pkgs.swaylock-effects}/bin/swaylock --screenshots --clock --indicator --indicator-radius 100 --indicator-thickness 7 --effect-blur 7x5 --effect-vignette 0.5:0.5 --ring-color bb00cc --key-hl-color 880033 --line-color 00000000 --inside-color 00000088 --separator-color 00000000 --grace 2 --fade-in 0.2";
      }
      # { event = "after-resume"; command = "hyprctl dispatch dpms on"; }
    ];
  };

  services.kanshi = {
    enable = true;
    profiles = {
      undocked = {
        outputs = [
          {
            criteria = "eDP-1";
          }
        ];
      };
      docked = {
        outputs = [
          {
            criteria = "eDP-1";
          }
          {
            criteria = "HDMI-A-1";
          }
        ];
      };
    };
  };

  programs.rtorrent = {
    enable = true;
    extraConfig = lib.readFile ./dotfiles/rtorrent.conf;
  };

  services.mpd = {
    enable = true;
    musicDirectory = "/home/kaptch/Music";
  };

  programs.beets = {
    enable = true;
    settings = {
      directory = "/home/kaptch/Music";
      library = "/home/kaptch/.musiclibrary.db";
      import = { move = true; copy = false; };
    };
    mpdIntegration = {
      enableStats = true;
      enableUpdate = true;
    };
  };

  programs.wofi = {
    enable = true;
    settings = {
      width = 600;
      height = 300;
      location = "center";
      show = "run";
      prompt = "Search...";
      filter_rate = 100;
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = true;
      image_size = 40;
      gtk_dark = true;
    };
  };

  services.blueman-applet = {
    enable = true;
  };

  programs.ledger = {
    enable = true;
    extraConfig = ''
      --sort date
      --effective
      --date-format %Y-%m-%d
    '';
    settings = {
      date-format = "%Y-%m-%d";
      file = [
        "~/Finances/journal.ledger.gpg"
      ];
      sort = "date";
      strict = true;
    };
  };

  services.gammastep = {
    enable = true;
    tray = true;
    dawnTime = "6:00-7:45";
    duskTime = "18:35-20:15";
    temperature.day = 6500;
    temperature.night = 3700;
  };

  # programs.khal = {
  #   enable = true;
  # };

  # programs.vdirsyncer = {
  #   enable = true;
  # };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        origin = "top-right";
        offset = "60x12";
        separator_height = 2;
        padding = 12;
        horizontal_padding = 12;
        text_icon_padding = 12;
        frame_width = 4;
        separator_color = "frame";
        idle_threshold = 120;
        font = "JetBrains Mono 12";
        line_height = 0;
        format = "<h3>%a%I</h3>\n<b>%s</b>\n%b\n%p";
        alignment = "center";
        icon_position = "off";
        startup_notification = "false";
        corner_radius = 12;
        progress_bar = true;
        frame_color = "#44465cbf";
        background = "#303241bf";
        foreground = "#d9e0eebf";
        timeout = 4;
      };
    };
  };

  # services.mako = {
  #   enable = true;
  #   layer = "overlay";
  #   font = "Ubuntu Nerd Font";
  #   width = 500;
  #   height = 80;
  #   defaultTimeout = 10000;
  #   maxVisible = 10;
  #   backgroundColor = "#000000AA";
  #   textColor = "#FFFFFF";
  #   borderColor = "#444444AA";
  #   progressColor = "over #11AA11";
  #   maxIconSize = 24;
  # };

  programs.mangohud = {
    enable = true;
    enableSessionWide = true;

    settings = {
      output_folder = "~/.mangologs";
      toggle_hud = "Shift_L+M";
      toggle_logging = "Control_L+M";
      reload_cfg = "Alt_L+M";

      cpu_stats = 1;
      cpu_temp = 1;
      gpu_stats = 1;
      gpu_temp = 1;
      ram = 1;
      frametime = 0;
      show_fps_limit = 1;
      wine = 1;
    };

    settingsPerApplication = {
      mpv = {
        no_display = true;
      };
    };
  };

  programs.navi.enable = true;

  systemd.user.services.nm-applet = {
    Unit = {
      Description = "Network Manager Applet";
      BindsTo = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
    };
    Service = {
      ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet --sm-disable --indicator";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # systemd.user.services.davmail = {
  #   Unit = {
  #     Description = "Davmail gateway";
  #     After = [ "default.target" ];
  #   };
  #   Install = {
  #     WantedBy = [ "default.target" ];
  #   };
  #   Service = {
  #     Type = "simple";
  #     RemainAfterExit= "no";
  #     ExecStart = "${pkgs.jre}/bin/java -jar ${pkgs.davmail}/share/davmail/davmail.jar";
  #     ExecStop = "killall davmail";
  #     RestartSec = 5;
  #     Restart = "always";
  #   };
  # };
}
