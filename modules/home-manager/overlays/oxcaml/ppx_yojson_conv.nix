{
  oxcaml,
  ocamlPackages,
  fetchurl,
  ...
}:
ocamlPackages.buildDunePackage {
  pname = "lsp";
  version = "1.19.0+ox";

  src = fetchurl {
    url = "https://github.com/janestreet/ppx_yojson_conv/archive/5dcf643373232005aa2452253dd5d7907789a4cd.tar.gz";
    sha256 = "sha256-fThHL6aMaqKDlB8V/kFV0EFkkE2yqXQJBLZ7Yv9EooI=";
  };

  duneInputs = with ocamlPackages; [
    oxcaml
    base
    ppx_js_style
    ppx_yojson_conv_lib
    ppxlib_jane
    ppxlib
  ];
}
