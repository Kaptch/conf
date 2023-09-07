{ inputs, config, lib, pkgs, ... }:
let
  steam-with-pkgs = pkgs.steam.override {
    extraPkgs = pkgs: with pkgs; [
      xorg.libXcursor
      xorg.libXi
      xorg.libXinerama
      xorg.libXScrnSaver
      libpng
      libpulseaudio
      libvorbis
      stdenv.cc.cc.lib
      libkrb5
      keyutils
      gamescope
      mangohud
    ];
  };

  tex = (pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-full
      biber
      biblatex
      cleveref
      dashbox
      environ
      gentium-tug
      ifmtarg
      iftex
      minted
      pbox
      scalerel
      totpages
      xifthen
      xstring;
  });

  my-python-packages = python-packages: with python-packages; [
    alectryon
    beautifulsoup4
    debugpy
    docutils
    jupyter
    matplotlib
    numpy
    pandas
    pip
    pygments
    python-lsp-server
    requests
    scikit-learn
    scipy
    scrapy
    seaborn
    web3
  ];
  python-with-my-packages = pkgs.python3.withPackages my-python-packages;

  pass = pkgs.pass.override { waylandSupport = true; };
  pass-ext = pass.withExtensions (ext: [ ext.pass-import
                                         ext.pass-genphrase
                                         ext.pass-otp
                                         ext.pass-update
                                         ext.pass-tomb]);

  pidgin-with-plugins = pkgs.pidgin.override {
    plugins = [ pkgs.pidgin-otr pkgs.pidgin-latex ];
  };

  agda = pkgs.agda.withPackages [ pkgs.agdaPackages.standard-library pkgs.agdaPackages.agda-categories pkgs.agdaPackages.cubical ];

  mattermost-fix = pkgs.writeShellScriptBin "mattermost-fix" ''
    exec mattermost-desktop -d ~/Mattermost
  '';

  steam-session = pkgs.writeShellScriptBin "steam-session" ''
    exec ${pkgs.gamescope}/bin/gamescope -e -- steam -gamepadui
  '';

  hyprland-gamemode-toggle = pkgs.writeShellScriptBin "hyprland-gamemode-toggle" ''
    HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==2{print $2}')
    if [ "$HYPRGAMEMODE" = 1 ] ; then
      hyprctl --batch "\
        keyword animations:enabled 0;\
        keyword decoration:drop_shadow 0;\
        keyword decoration:blur 0;\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;\
        keyword general:border_size 1;\
        keyword misc:vrr 0;\
        keyword decoration:rounding 0"
      exit
   fi
   hyprctl reload
   '';

  ncoq = pkgs.coq_8_16;
  ncoqPackages = pkgs.coqPackages_8_16;
in
{
  imports =
    [
      ./bash.nix
      ./git.nix
      ./emacs.nix
      ./tmux.nix
      ./alacritty.nix
      ./obs.nix
      ./waybar.nix
      # ./hyprland.nix
      ./sway.nix
      ./services.nix
      ./vim.nix
      ./wlogout.nix
      ./zathura.nix
    ];

  programs.home-manager.enable = true;

  programs.gpg.enable = true;

  programs.browserpass.enable = true;

  # programs.opam = {
  #   enable = true;
  #   enableBashIntegration = true;
  # };

  programs.zathura = {
    enable = true;
  };

  programs.go = {
    enable = true;
    package = pkgs.go_1_18;
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.mbsync = {
    enable = true;
    extraConfig = "Sync Pull\n";
  };

  programs.msmtp = {
    enable = true;
  };

  programs.mu.enable = true;

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    extensions = with pkgs.vscode-extensions; [
      github.codespaces
      # github.copilot
      matklad.rust-analyzer
      mkhl.direnv
      kahole.magit
      vadimcn.vscode-lldb
      bungcip.better-toml
      ms-vsliveshare.vsliveshare
      ocamllabs.ocaml-platform
      james-yu.latex-workshop
      dracula-theme.theme-dracula
      maximedenes.vscoq
    ];
  };

  programs.neomutt = {
    enable = true;
    sidebar.enable = true;
    editor = "emacsclient -c";
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  accounts.email = {
    accounts = {
      kaptch = {
        address = "kaptch@gmail.com";
        gpg = {
          key = "E28D035B17973498838DF2FC2468D8CD84976F6E";
          signByDefault = true;
        };
        imap = {
          host = "imap.gmail.com";
        };
        mbsync = {
          enable = true;
          create = "maildir";
          extraConfig.account = {
            AuthMechs = "LOGIN";
            SSLType = "IMAPS";
          };
          extraConfig.channel = {
            MaxMessages = 1000;
            ExpireUnread = "yes";
          };
        };
        msmtp = {
          enable = true;
          extraConfig = {
            auth = "on";
            tls_starttls = "on";
            logfile = "~/.msmtp.log";
          };
        };
        # imapnotify = {
        #   enable = true;
        #   boxes = [ "Inbox" ];
        #   onNotifyPost = "${pkgs.libnotify}/bin/notify-send 'New mail in %s'";
        # };
        mu.enable = true;
        neomutt.enable = true;
        primary = true;
        realName = "Sergei Stepanenko";
        signature = {
          text = ''
          Kind regards/Med venlig hilsen,
          Sergei
        '';
          showSignature = "append";
        };
        passwordCommand = "echo $(INSIDE_EMACS='YES' gpg2 -q --for-your-eyes-only --no-tty -d /home/kaptch/.authinfo.gpg 2> /dev/null | awk '/machine smtp.gmail.com login kaptch@gmail.com/ {print $NF}' 2> /dev/null)";
        smtp = {
          host = "smtp.gmail.com";
          port = 587;
        };
        userName = "kaptch@gmail.com";
      };
      au = {
        address = "sergei.stepanenko@cs.au.dk";
        gpg = {
          key = "E28D035B17973498838DF2FC2468D8CD84976F6E";
          signByDefault = true;
        };
        imap = {
          host = "127.0.0.1";
          port = 1143;
          tls.enable = false;
        };
        mbsync = {
          # fixme
          enable = false;
          create = "maildir";
          extraConfig.account = {
            AuthMechs = "LOGIN";
          };
          extraConfig.channel = {
            MaxMessages = 1000;
            ExpireUnread = "yes";
          };
        };
        msmtp = {
          enable = true;
          extraConfig = {
            auth = "login";
            tls = "off";
            logfile = "~/.msmtp.log";
          };
        };
        mu.enable = true;
        neomutt.enable = true;
        primary = false;
        realName = "Sergei Stepanenko";
        signature = {
          text = ''
          Kind regards/Med venlig hilsen,
          Sergei
        '';
          showSignature = "append";
        };
        passwordCommand = "echo $(INSIDE_EMACS='YES' gpg2 -q --for-your-eyes-only --no-tty -d /home/kaptch/.authinfo.gpg 2> /dev/null | awk '/machine au login au671308@uni.au.dk/ {print $NF}' 2> /dev/null)";
        smtp = {
          host = "localhost";
          port = 1025;
        };
        userName = "au671308@uni.au.dk";
      };
    };
  };

  home.username = "kaptch";
  home.homeDirectory = "/home/kaptch";
  home.packages = with pkgs; [
    zeroad
    inputs.comma.packages."${system}".default
    agda
    aircrack-ng
    alacritty
    anki-bin
    ardour
    baobab
    bettercap
    binutils
    bitwarden
    bitwarden-cli
    bitcoin
    blender
    brightnessctl
    btop
    cage
    cataclysm-dda
    cava
    # TODO: config
    # ~/.config/calibre
    # calibre
    chromium
    clippy
    cozy
    crawlTiles
    crow-translate
    cutter
    davmail
    delta
    direnv
    discord
    docker-compose
    dsniff
    element-desktop
    elinks
    emacs-all-the-icons-fonts
    erlang-ls
    erlfmt
    (ffmpeg.override {
      withV4l2 = true;
    })
    firefox
    font-awesome
    # freecad
    gamemode
    gamescope
    gh
    ghidra
    gimp
    gnome3.adwaita-icon-theme
    gnumake
    go-ethereum
    gopls
    gore
    gpa
    grim
    gtk-layer-shell
    gtklp
    guitarix
    haskell-language-server
    hyprpicker
    hyprland-gamemode-toggle
    helvum
    hicolor-icon-theme
    i2pd
    icu
    iftop
    imagemagick
    imv
    ispell
    jetbrains.idea-community
    jdk
    kanshi
    kicad-small
    kismet
    khal
    ledger-live-desktop
    # libreoffice
    # ltex-ls
    lutris
    macchanger
    mattermost-desktop
    mattermost-fix
    meson
    metasploit
    minetest
    mkchromecast
    monero-gui
    monero-cli
    mpv
    ncmpcpp
    nnn
    ncoq
    ncoqPackages.autosubst
    ncoqPackages.category-theory
    ncoqPackages.equations
    ncoqPackages.iris
    ncoqPackages.mathcomp-ssreflect
    ncoqPackages.metacoq
    # ncoqPackages.metacoq-pcuic
    ncoqPackages.serapi
    ncoqPackages.stdpp
    ncoqPackages.coq-elpi
    ncoqPackages.coq-lsp
    neovide
    networkmanagerapplet
    nixopsUnstable
    ocamlPackages.ocaml-lsp
    ocamlPackages.elpi
    openconnect
    openssl
    otpclient
    organicmaps
    pamixer
    papirus-icon-theme
    parted
    pass-ext
    patchelf
    pavucontrol
    pcmanfm
    pioneer
    pidgin-with-plugins
    pinentry-gtk2
    pkg-config
    playerctl
    pmbootstrap
    polkit-kde-agent
    prismlauncher
    profanity
    proton-caller
    protontricks
    # prusa-slicer
    pulseaudio
    pwgen
    python-with-my-packages
    qbittorrent
    qemu
    qtpass
    radare2
    reaverwps
    rust-analyzer
    rustfmt
    samba
    sbcl
    sc-im
    screenfetch
    signal-desktop
    sharing
    slurp
    solc
    spotify
    steam-with-pkgs
    steam-session
    steam-run
    sway-contrib.grimshot
    swayidle
    swaylock-fancy
    syncthingtray
    system-config-printer
    tdesktop
    tex
    thunderbird-wayland
    tmux
    tor
    tor-browser-bundle-bin
    typst
    typst-lsp
    typst-fmt
    typespeed
    qt6.qtwayland
    udisks
    unzip
    vial
    virt-manager
    vlc
    wdisplays
    wesnoth
    wev
    weylus
    material-design-icons
    bibata-cursors
    (wf-recorder.override {
      ffmpeg = (ffmpeg.override {
        withV4l2 = true;
      });
    })
    wget
    wireguard-tools
    wireshark
    wl-clipboard
    wlogout
    xdg-desktop-portal-hyprland
    xdg-utils
    xoscope
    xwayland
    vulkan-tools
    xz
    youtube-dl
    yubikey-manager
    yubikey-manager-qt
    yubikey-personalization
    yubikey-personalization-gui
    yubioath-flutter
    zoom-us
  ];

  xdg.mimeApps.defaultApplications = {
    "application/x-extension-htm" = "firefox.desktop";
    "application/x-extension-html" = "firefox.desktop";
    "application/x-extension-shtml" = "firefox.desktop";
    "application/x-extension-xht" = "firefox.desktop";
    "application/x-extension-xhtml" = "firefox.desktop";
    "application/xhtml+xml" = "firefox.desktop";
    "text/html" = "firefox.desktop";
    "x-scheme-handler/chrome" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
  };
  xdg.desktopEntries = {
    elinks = {
      name = "ELinks";
      genericName = "Web Browser";
      exec = "alacritty -e elinks";
      terminal = false;
      categories = [ "Application" "Network" "WebBrowser" ];
      mimeType = [ "text/html" "text/xml" ];
    };
    profanity = {
      name = "profanity";
      genericName = "XMPP client";
      exec = "alacritty -e profanity";
      terminal = false;
      categories = [ "Application" "Network" ];
    };
    irssi = {
      name = "irssi";
      genericName = "IRC client";
      exec = "alacritty -e  irssi";
      terminal = false;
      categories = [ "Application" "Network" ];
    };
    neomutt = {
      name = "neomutt";
      genericName = "Email client";
      exec = "alacritty -e neomutt";
      terminal = false;
      categories = [ "Application" "Network" ];
    };
    nnn = {
      name = "nnn";
      genericName = "File manager";
      exec = "alacritty -e nnn";
      terminal = false;
      categories = [ "Application" ];
    };
    newsboat = {
      name = "newsboat";
      genericName = "RSS";
      exec = "alacritty -e newsboat";
      terminal = false;
      categories = [ "Application" ];
    };
  };
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    extraConfig = {
      XDG_AUDIO_DIR = "$HOME/Audio";
      XDG_BOOKS_DIR = "$HOME/Books";
      XDG_EDU_DIR = "$HOME/Edu";
      XDG_FINANCES_DIR = "$HOME/Finances";
      XDG_CALENDAR_DIR = "$HOME/Calendars";
      XDG_GAMES_DIR = "$HOME/Games";
      XDG_MAILDIR_DIR = "$HOME/Maildir";
      XDG_ORG_DIR = "$HOME/Org";
      XDG_SCREENSHOTS_DIR = "$HOME/Pictures/Screenshots";
      XDG_WALLPAPER_DIR = "$HOME/Pictures/wallpapers";
      XDG_PROJECTS_DIR = "$HOME/Projects";
      XDG_SCRIPTS_DIR = "$HOME/Scripts";
      XDG_SECRETS_DIR = "$HOME/Secrets";
      XDG_MISC_DIR = "$HOME/Misc";
      XDG_TEMP_DIR = "$HOME/Temp";
    };
  };
  home.file.".davmail.properties".source = ./dotfiles/davmail.properties;
  xdg.configFile."nwg-drawer/drawer.css".source = ./dotfiles/nwg-drawer.css;
  xdg.configFile."khal/config".source = ./dotfiles/khal;
  xdg.configFile."waybar/nix-snowflake.jpg".source = ./dotfiles/nix-snowflake.jpg;
  xdg.configFile."swaylock/config" = {
    text = lib.concatStrings (lib.mapAttrsToList (n: v:
      if v == false then
        ""
      else
        (if v == true then n else n + "=" + builtins.toString v) + "\n")
      {
        color = "#000000";
        font-size = 24;
        indicator-idle-visible = false;
        indicator-radius = 100;
        line-color = "12175c";
        show-failed-attempts = true;
      });
  };
  xdg.configFile."discord/settings.json" = {
    text = builtins.toJSON {
      SKIP_HOST_UPDATE = true;
      BACKGROUND_COLOR = "#202225";
      IS_MAXIMIZED = true;
      IS_MINIMIZED = false;
    };
  };
  gtk = {
    enable = true;
    cursorTheme.package = pkgs.bibata-cursors;
    cursorTheme.name = "Bibata-Original-Ice";
    cursorTheme.size = 24;
  };
}
