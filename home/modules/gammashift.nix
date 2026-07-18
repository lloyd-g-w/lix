{pkgs, ...}: {
  services.gammastep = {
    enable = true;

    # Same strong warmth at all times
    temperature = {
      day = 4500;
      night = 4500;
    };

    # Still required, despite identical temperatures
    dawnTime = "6:00-7:45";
    duskTime = "18:35-20:15";

    settings = {
      general = {
        adjustment-method = "wayland";
        fade = 0;
      };
    };

    tray = true;
  };
}
