{ config, pkgs, inputs, ... }:

{

  nixpkgs.config.allowUnfree = true;

  imports = [
    ./zsh.nix
  ];

  home.username = "rop2bash";
  home.homeDirectory = "/home/rop2bash";

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    fastfetch
    
    p7zip
    btop
    firefox
    nerdfonts

    (discord.overrideAttrs (e: {
      desktopItem = e.desktopItem.override (d: {
        exec = "${d.exec} --disable-gpu";
        });
      installPhase = builtins.replaceStrings [ "${e.desktopItem}" ] [ "${desktopItem}" ] e.installPhase;
      })
    )
    (armcord.overrideAttrs (f: p: {
      desktopItems = [ ((builtins.elemAt p.desktopItems 0).override (d: {
        exec = "${d.exec} --disable-gpu";
        }))
      ];
      })
    )
    (google-chrome.override {
      commandLineArgs = [
        "--disable-gpu"
      ];
    })

    dolphin ranger
    pavucontrol
    eza

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  home.file = {
    # ".screenrc".source = dotfiles/screenrc;
    "${config.xdg.configHome}/hypr" = {
      source = ../dotfiles/hypr;
      recursive = true;
    };

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    ".config/zed/settings.json".text = ''
      {
        "telemetry": {
          "metrics": false,
          "diagnostics": false
        },
        "auto_update": false,
        "vim_mode": true,
        "ui_font_size": 16,
        "buffer_font_size": 16,
        "terminal": {
          "dock": "bottom",
          "font_family": "SauceCodePro Nerd Font"
        },
        "buffer_font_family": "SauceCodePro Nerd Font",
        "ui_font_family": "SauceCodePro Nerd Font",
        "git": {
          "inline_blame": {
            "enabled": false
          }
        },
        "theme": {
          "mode": "dark",
          "light": "One Light",
          "dark": "Catppuccin Mocha - No Italics"
        },
        "lsp": {
          "rust-analyzer": {
            "binary": {
              "path": "${pkgs.rust-analyzer}/bin/rust-analyzer"
            },
            "initialization_options": {
              "checkOnSave": {
                "command": "clippy"
              }
            }
          }
        }
      }
    '';
  };

  home.sessionVariables = {
    EDITOR = "vim";
  };

  systemd.user.startServices = "sd-switch";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "rop2bash";
    userEmail = "rop2bash@gmail.com";
  };
  programs.nnn.enable = true;
  fonts.fontconfig.enable = true;

  home.stateVersion = "23.11"; # Please read the comment before changing.
}
