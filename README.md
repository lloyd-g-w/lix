# lix | nixos config
## building
### hardware configuration
It is necessary to have `hardware-configuration.nix` in the source directory to build the os. Either move it yourself or run
```bash
sudo nixos-generate-config && sudo cp /etc/nixos/hardware-configuration.nix .
```
to generate a new one if it doesn't already exist and move it to the source directory.
### monitors
If you are using a multi-monitor setup, you may want to configure your monitor layout in hyprland. To do so, create a `monitors.nix` file in `/hypr` and include your monitor configurations in an array. For example, the file could contain
```nix
[ "DP-4, preferred, 0x0, 1" "HDMI-A-2, preferred, auto, 1" ].
```
