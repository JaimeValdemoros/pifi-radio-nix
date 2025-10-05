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
  empty-json = writeText "empty.json" (builtins.toJSON { });
in
  portableService {
    pname = "pifi-radio";
    inherit (pifi) version;
    units = [
      (writeText "pifi-radio.service" ''
        [Unit]
        Description=pifi-radio web service

        [Service]
        Environment=PORT=3000
        Environment=PIFI_CONFIG_PATH=${empty-json}
        Environment=PIFI_STREAM_PATH=${empty-json}
        Environment=PIFI_DEFAULT_MPD_HOST=/run/pifi-radio/mpd.sock
        BindPaths=/run/pifi-radio
        ExecStart=/bin/pifi --port $PORT

        [Install]
        WantedBy=multi-user.target default.target'')
      (writeText "pifi-radio-mpd.service" (
        # Pass config file as part of mpd execution
        (builtins.replaceStrings ["--systemd"] ["--systemd $CONFIG_FILE"] (
          builtins.readFile "${mpd}/etc/systemd/system/mpd.service"
        ))
        + ''
          [Service]
          Environment=CONFIG_FILE=${mpd-conf}
        ''
      ))
      (writeText "pifi-radio-mpd.socket" ''
        [Socket]
        ListenStream=%t/pifi-radio/mpd.sock

        [Install]
        WantedBy=sockets.target
      '')
    ];
    symlinks = [
      {
        object = "${pifi}/bin/pifi";
        symlink = "/bin/pifi";
      }
    ];
  }
