{inputs, ...}: {
  imports = [inputs.lec.nixosModules.default];
  secrets.allowedUsers = ["lloyd"];
}
