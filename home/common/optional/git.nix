{
  pkgs,
  hostSpec,
  ...
}: {
  environment.systemPackages = with pkgs; [
    gitFull
  ];

  programs.git = {
    enable = true;
    userName = hostSpec.handle;
    userEmail = hostSpec.email;

    config.safe.directory = [
        "/etc/nixos"
    ];
  };
}
