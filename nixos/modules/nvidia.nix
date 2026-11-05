{pkgs, ...}: {
  # Setup Nvidia drivers
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [pkgs.nvidia-vaapi-driver];
  };

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia.open = true;

  # Save video memory across suspend (to /var/tmp) and run NVIDIA's
  # suspend/resume hooks. Without this, resume hung and needed a hard reset.
  hardware.nvidia.powerManagement.enable = true;

  nixpkgs.config.allowUnfree = true; # required for proprietary drivers
}
