{
  lib,
  bundlerApp,
  defaultGemConfig,
}:
bundlerApp {
  pname = "pifi";
  gemdir = ./.;
  gemConfig =
    defaultGemConfig
    // {
      pifi = attrs: {
        dontBuild = false;
        patches = [
          # Enable PIFI_CONFIG_PATH to set path for config.json
          ./patches/0000_config_getter.rb.patch
          # Fix for undefined method `exists?' for class File (NoMethodError) in ruby-mpd
          # https://idogawa.dev/p/2023/01/file-exists-ruby.html
          ./patches/0001_file_exists.rb.patch
        ];
      };
    };
  exes = ["pifi"];
}
