# Nix settings shared by all hosts.
_: {
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    builders-use-substitutes = true;
    substituters = [ "https://nix-community.cachix.org" ];
    trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
  };
}
