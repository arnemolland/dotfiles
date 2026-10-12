{ pkgs, ... }:

let
  # pkgs.edge's androidenv: React Native 0.87 compiles against Android 37,
  # which 25.11's SDK catalogue doesn't carry yet.
  #
  # Read-only SDK: Gradle can't download into it, so it must already hold
  # what projects compile against. Covers React Native 0.86–0.87 / Expo.
  sdk =
    (pkgs.edge.androidenv.composeAndroidPackages {
      platformVersions = [
        "36"
        "37.0"
      ];
      buildToolsVersions = [
        "36.0.0"
        "37.0.0"
      ];
      includeNDK = true;
      ndkVersions = [ "27.1.12297006" ];
      cmakeVersions = [ "3.22.1" ];
    }).androidsdk;

  sdkRoot = "${sdk}/libexec/android-sdk";
in
{
  # Android SDK command-line tools: sdkmanager, avdmanager, adb, fastboot,
  # build-tools, NDK.
  environment.systemPackages = [
    sdk
    pkgs.jdk17
  ];

  environment.variables = {
    ANDROID_HOME = sdkRoot;
    ANDROID_SDK_ROOT = sdkRoot;
    ANDROID_NDK_ROOT = "${sdkRoot}/ndk-bundle";
    JAVA_HOME = pkgs.jdk17.home;
  };

  # Let adb reach USB devices (ADB/fastboot interfaces) without root.
  # systemd's uaccess rules need a local seat, which WSL sessions lack.
  users.groups.adbusers = { };
  users.users.arne.extraGroups = [ "adbusers" ];
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ENV{ID_USB_INTERFACES}=="*:ff420?:*", MODE="0660", GROUP="adbusers"
  '';
}
