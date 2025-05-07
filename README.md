# lix | my personal nixos config
## building
### hardware configuration
It is neccessary to include `hardware-configuration.nix` to build the os. To do so, feel to free to run
```bash
sudo nixos-generate-config --root / && sudo cp /etc/nixos/hardware-configuration.nix .
```
from the main lix folder.
### monitors
If you are using a multi-monitor setup, you may want to configure how the monitors are layed out in hyprland. To do so, simply create a `monitors.nix` file in `/hypr` and include your configuration in it. For example, the file could contain
```nix
[ "DP-4, preferred, 0x0, 1" "HDMI-A-2, preferred, auto, 1" ].
```
