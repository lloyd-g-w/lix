{config, ...}: {
  perSystem = {...}: {
    _module.args.lix = config.lix; # Expose top level lix arg as perSystem arg

    imports = [
      ./dev
      ./switch
    ];
  };
}
