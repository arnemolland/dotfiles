{ config, pkgs, ... }:
{
  # iOS development without a Mac: Swift toolchain, xtool, and
  # libimobiledevice for talking to devices over usbmuxd.

  # Daemon runs as a system service; udev hands it Apple devices.
  services.usbmuxd.enable = true;

  environment.systemPackages = with pkgs; [
    swift-fhs # swift, swiftc, sourcekit-lsp, docc, lldb, swift-env
    xtool
    config.services.usbmuxd.package # usbmuxd CLI (the module only runs it)
    libimobiledevice # ideviceinfo, idevicesyslog, ...
    cocoapods
  ];
}
