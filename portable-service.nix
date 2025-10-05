{
  concatText,
  mpd,
  portableService,
  pifi,
}:
portableService {
  pname = "pifi-radio";
  inherit (pifi) version;
  units = [
    (concatText "pifi-radio.service" [./systemd/pifi-radio.service])
    (concatText "pifi-radio-mpd.service" ["${mpd}/etc/systemd/system/mpd.service"])
    (concatText "pifi-radio-mpd.socket" ["${mpd}/etc/systemd/system/mpd.socket" ])
  ];
  symlinks = [
    {
      object = "${pifi}/bin/pifi";
      symlink = "/bin/pifi";
    }
  ];
}
