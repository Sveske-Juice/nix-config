{config, ...}: {
    imports = [
        ./core.nix
    ];
    services.syncthing = {
        settings = {
            gui = {
                user = config.hostSpec.username;
                password = "$2b$05$I0ofnse7HEEVqyvgjwD3FOLGiXHbobSUURvud3iR3z6LKi461puyS";
            };
        };
    };
}
