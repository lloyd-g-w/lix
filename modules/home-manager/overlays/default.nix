self: super: {
  # The attribute name 'oxcaml' is how you will refer to the package.
  # It imports the derivation from the oxcaml subdirectory.
  oxcaml = self.callPackage ./oxcaml {};
}
