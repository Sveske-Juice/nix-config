{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    monado-vulkan-layers
    opencomposite
    xrizer
    openxr-loader
    wlx-overlay-s
  ];
  imports = [
    inputs.nixpkgs-xr.nixosModules.nixpkgs-xr
  ];

  services.monado = {
    enable = true;
    defaultRuntime = true;
  };

  services.wivrn = {
    enable = true;
    openFirewall = true;

    # Write information to /etc/xdg/openxr/1/active_runtime.json, VR applications
    # will automatically read this and work with WiVRn (Note: This does not currently
    # apply for games run in Valve's Proton)
    defaultRuntime = true;

    # Run WiVRn as a systemd service on startup
    autoStart = true;

    # Config for WiVRn (https://github.com/WiVRn/WiVRn/blob/master/docs/configuration.md)
    config = {
      enable = true;
      json = {
        # 1.0x foveation scaling
        scale = 1.0;
        # 100 Mb/s
        bitrate = 100000000;
        encoders = [
          {
            encoder = "vaapi";
            codec = "h265";
            # 1.0 x 1.0 scaling
            width = 1.0;
            height = 1.0;
            offset_x = 0.0;
            offset_y = 0.0;
          }
        ];
      };
    };
  };
  programs.envision = {
    enable = true;
    openFirewall = true; # This is set true by default
  };

  xdg.configFile."openvr/openvrpaths.vrpath".text = ''
    {
      "config" :
      [
        "~/.local/share/Steam/config"
      ],
      "external_drivers" : null,
      "jsonid" : "vrpathreg",
      "log" :
      [
        "~/.local/share/Steam/logs"
      ],
      "runtime" :
      [
        "${pkgs.opencomposite}/lib/opencomposite"
      ],
      "version" : 1
    }
  '';
}
