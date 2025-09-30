{ bundlerApp }:
bundlerApp {
  pname = "pifi";
  gemdir = ./.;
  exes = [ "pifi" ];
}
