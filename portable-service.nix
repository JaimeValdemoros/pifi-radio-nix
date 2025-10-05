{
  portableService,
  pifi,
}:
portableService {
  pname = "pifi-radio";
  inherit (pifi) version;
  units = [];
}
