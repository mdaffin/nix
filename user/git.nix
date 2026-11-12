_: {
  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.commentString = ";;";
    };

    ignores = [
      # direnv
      ".direnv/"
      ".envrc.local"

      # symlinks nix build creates.
      "result"
      "result-*"

      # Editors
      ".idea/"
      "*.iml"
      ".vscode/"
      "*.swp"
      "*.swo"
      "*~"
      ".history/"
    ];
  };
}
