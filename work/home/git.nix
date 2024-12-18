{
  lib,
  ...
}:
{
  programs.git = {
    enable = true;
    userName = "Michael Daffin";
    userEmail = "michael.daffin@starlingbank.com";

    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      gpg.format = "ssh";
      # push.default = "current";
      # merge.conflictstyle = "diff3";
      # diff.colorMoved = "default";
    };

    ignores = [ ];

    signing = {
      key = "~/.ssh/id_ed25519_starling.pub";
      signByDefault = true;
    };

    delta = {
      enable = true;
    };
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };
}
