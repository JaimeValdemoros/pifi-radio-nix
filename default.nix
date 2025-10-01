{ lib, bundlerApp, defaultGemConfig }:
bundlerApp {
  pname = "pifi";
  gemdir = ./.;
  gemConfig = defaultGemConfig // {
    pifi = attrs: {
      dontBuild = false;
      patches = [ ./config_getter.rb.patch ];
    };
  };
  exes = [ "pifi" ];
}
