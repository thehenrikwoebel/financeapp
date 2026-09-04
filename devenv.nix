{
  pkgs,
  lib,
  config,
  ...
}:
{
  # devenv.sh/packages/
  packages = [
    pkgs.git
  ];

  # devenv.sh/languages/
  languages = {
    dart.enable = true;
  };

  # devenv.sh/android/
  android = {
    enable = true;
    flutter.enable = true;
  };
}