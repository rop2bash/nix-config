{ config, pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # enableAutosuggestions = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ls = "eza";
      ll = "ls -l";
    };

    history.size = 10000;
    history.path = "${config.xdg.dataHome}/zsh/history";

    #oh-my-zsh = {
    #  enable = true;
    #  plugins = [ "git" "sudo" ];
    #  theme = "agnoster"; # blinks is also really nice
    #};
  };
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = pkgs.lib.importTOML ../dotfiles/starship.toml;
  };
}
