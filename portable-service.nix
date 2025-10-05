{
  concatText,
  mpd,
  portableService,
  pifi,
  writeText,
}: let
  mpd-conf = writeText "mpd.conf" ''
    audio_output {
        type            "fifo"
        name            "snapcast"
        path            "/tmp/snapfifo/pifi"
        format          "48000:16:2"
        mixer_type      "software"
    }
  '';
  empty-json = writeText "empty.json" (builtins.toJSON {});
  pifi-service = writeText "pifi.service" ''
    [Unit]
    Description=pifi web service

    [Service]
    Environment=PORT=3000
    Environment=PIFI_CONFIG_PATH=${empty-json}
    Environment=PIFI_STREAM_PATH=${empty-json}
    Environment=PIFI_DEFAULT_MPD_HOST=/run/pifi/mpd.sock
    BindPaths=/run/pifi
    ExecStart=${pifi}/bin/pifi --port $PORT

    [Install]
    WantedBy=multi-user.target default.target
  '';
  pifi-mpd-service = writeText "pifi-mpd.service" (
    # Pass config file as part of mpd execution
    (builtins.replaceStrings ["--systemd"] ["--systemd $CONFIG_FILE"] (
      builtins.readFile "${mpd}/etc/systemd/system/mpd.service"
    ))
    + ''
      [Service]
      Environment=CONFIG_FILE=${mpd-conf}
    ''
  );
  pifi-mpd-socket = writeText "pifi-mpd.socket" ''
    [Socket]
    ListenStream=%t/pifi/mpd.sock

    [Install]
    WantedBy=sockets.target
  '';
in
  portableService {
    pname = "pifi";
    inherit (pifi) version;
    units = [
      pifi-service
      pifi-mpd-service
      pifi-mpd-socket
    ];
  }
