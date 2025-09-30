{ pkgs, config, lib, ... }:
let cfg = config.services.pifi; in {
  options = {
    services.pifi = {
      enable = lib.mkEnableOption "pifi";
      package = lib.mkOption {
        description = "pifi package to use";
        type = lib.types.package;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.pifi = {
      description = "Run the pifi web interface";
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/pifi";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
