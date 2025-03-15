{hostname ? "server"}: {...}: {
    networking.hostName = hostname;
    networking.hostId = "0363c4ad";
    networking.networkmanager.enable = false;
    networking.useNetworkd = true;
    # networking.firewall = {
    #     enable = true;
    #     allowedTCPPorts = [];
    #     allowedUDPPorts = [];
    # };
}
