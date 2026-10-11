{ pkgs, ... }:
{
  # iOS development without a Mac: Swift toolchain, xtool, and
  # libimobiledevice for talking to devices over usbmuxd.

  # Starts on demand (udev) when an Apple device shows up.
  services.usbmuxd.enable = true;

  environment.systemPackages = with pkgs; [
    swift-fhs # swift, swiftc, sourcekit-lsp, docc, lldb, swift-env
    xtool
    libimobiledevice # ideviceinfo, idevicesyslog, ...
    cocoapods
  ];
}
