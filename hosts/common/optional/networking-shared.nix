{hostname ? throw "no hostname"}: {...}: {
    networking.hostName = hostname;
    networking.hostId = "0363c4ad";
}
