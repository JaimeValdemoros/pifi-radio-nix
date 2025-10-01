{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.services.pifi;
in {
  options.services.pifi = {
    enable = lib.mkEnableOption "pifi";
    package = lib.mkOption {
      description = "pifi package to use";
      type = lib.types.package;
    };
    port = lib.mkOption {
      description = "Port to run on";
      type = lib.types.int;
      default = 3000;
    };
    mpd_host = lib.mkOption {
      description = "MPD host";
      type = lib.types.str;
      default = "127.0.0.1";
    };
    mpd_port = lib.mkOption {
      description = "MPD port";
      type = lib.types.int;
      default = 6600;
    };
    mpd_pass = lib.mkOption {
      description = "MPD password";
      type = lib.types.str;
      default = "";
    };
    streams = lib.mkOption {
      description = "Stream URLs";
      type = lib.types.attrsOf lib.types.str;
      default = {};
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.pifi = {
      description = "Run the pifi web interface";
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/pifi --port ${builtins.toString cfg.port}";
      };
      environment.PIFI_CONFIG_PATH =
        pkgs.writeText "config.json"
        (
          builtins.toJSON {
            mpd_host = cfg.mpd_host;
            mpd_port = cfg.mpd_port;
            mpd_password = cfg.mpd_pass;
            streams_path = (pkgs.writeText "streams.json" (builtins.toJSON cfg.streams)).outPath;
          }
        ).outPath;
      wantedBy = ["multi-user.target"];
    };
  };
}
