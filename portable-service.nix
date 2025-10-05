{
  concatText,
  portableService,
  pifi,
}:
portableService {
  pname = "pifi-radio";
  inherit (pifi) version;
  units = [
    (concatText "pifi-radio.service" [./systemd/pifi-radio.service])
  ];
  symlinks = [
    {
      object = "${pifi}/bin/pifi";
      symlink = "/bin/pifi";
    }
  ];
}
