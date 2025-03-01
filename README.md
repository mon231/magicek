# Magicek

A Magisk module to start [CheatEngine](https://github.com/cheat-engine/cheat-engine) ceserver on boot with automatic architecture detection.

## Features

- Automatic architecture detection (arm/arm64/x86/x86_64)
- Starts ceserver automatically on boot
- Monitors and restarts ceserver if it crashes
- Logging to /data/local/tmp/magicek.log
- Automatic updates via Magisk Manager

## Installation

1. Download the latest release from the [Releases](https://github.com/mon231/magicek/releases) page
2. Install the module through Magisk Manager
3. Reboot your device

## Usage

After installation and reboot, ceserver will automatically start in the background. You can connect to it using CheatEngine from your PC:

1. Open CheatEngine on your PC
2. Click on the "Connect to Android/iOS" button
3. Enter your device's IP address
4. Click "Connect"

## Updates

The module supports automatic updates through Magisk Manager. When a new version is released on GitHub, you'll receive a notification in Magisk Manager.

To manually check for updates:
1. Open Magisk Manager
2. Go to Modules
3. Find Magicek and tap the update button if available

## Troubleshooting

If you encounter any issues:

1. Check the log file at `/data/local/tmp/magicek.log`
2. Make sure your device is properly rooted with Magisk
3. Verify that the module is enabled in Magisk Manager
4. If ceserver crashes repeatedly, try reinstalling the module or updating to the latest version

## Supported Architectures

- ARM (32-bit)
- ARM64 (64-bit)
- x86 (32-bit)
- x86_64 (64-bit)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Credits

- [CheatEngine](https://github.com/cheat-engine/cheat-engine) for the ceserver binaries
- [Magisk](https://github.com/topjohnwu/Magisk) for the module system
