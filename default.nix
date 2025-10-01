{
  lib,
  bundlerApp,
  defaultGemConfig,
  ruby_3_1,
}:
bundlerApp {
  pname = "pifi";
  gemdir = ./.;
  gemConfig =
    defaultGemConfig
    // {
      pifi = attrs: {
        dontBuild = false;
        patches = [./config_getter.rb.patch];
      };
    };
  exes = ["pifi"];
  # ruby-mpd-0.3.3/lib/ruby-mpd.rb:273:in `socket': undefined method `exists?' for class File (NoMethodError)
  # `exists?` was removed in ruby 3.2:
  # https://stackoverflow.com/questions/14351272/undefined-method-exists-for-fileclass-nomethoderror
  ruby = ruby_3_1;
}
