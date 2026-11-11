{inputs, ...}: {
  # lec's secrets in /run/secrets, readable by root only.
  imports = [inputs.lec.nixosModules.default];
}
