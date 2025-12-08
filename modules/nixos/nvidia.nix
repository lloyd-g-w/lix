{pkgs, ...}: {
  # Setup Nvidia drivers
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [pkgs.nvidia-vaapi-driver];
  };

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia.open = true;
}
