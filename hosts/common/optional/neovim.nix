{ self, pkgs, ... }:
{
  environment.systemPackages = [ self.packages.${pkgs.stdenv.system}.neovim ];
}
