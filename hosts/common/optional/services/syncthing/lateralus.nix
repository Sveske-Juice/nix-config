{config, ...}: {
    imports = [
        ./core.nix
    ];
    services.syncthing = {
        settings = {
            gui = {
                # TODO: once password file PR is merged use sops-nix
                password = "$2b$05$3CAJfvW.hPw9l76.D0HLTu39YoSgdyoLg66zvicutMGzdP.99jUna";
            };
        };
    };
}
