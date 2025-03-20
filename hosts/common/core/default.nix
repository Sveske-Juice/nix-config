{
    lib,
    pkgs,
    ...
}:
{
	imports = [
        ../../../modules/common
		./sops.nix
	];
}
