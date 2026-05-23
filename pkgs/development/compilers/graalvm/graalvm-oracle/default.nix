{
  lib,
  stdenv,
  fetchurl,
  graalvmPackages,
  useMusl ? false,
  version ? "25",
}:

let
  updateScript =
    if
      builtins.elem version [
        "17"
        "25"
      ]
    then
      {
        command = [
          ./update.sh
          version
        ];
        attrPath =
          if version == "25" then
            "graalvmPackages.graalvm-oracle"
          else
            "graalvmPackages.graalvm-oracle_${version}";
        supportedFeatures = [ "commit" ];
      }
    else
      null;
in
(graalvmPackages.buildGraalvm {
  inherit useMusl version;
  src = fetchurl (import ./hashes.nix).${version}.${stdenv.system};
  meta.platforms = builtins.attrNames (import ./hashes.nix).${version};
  meta.license = lib.licenses.unfree;
  pname = "graalvm-oracle";
}).overrideAttrs
  (previousAttrs: {
    passthru = (previousAttrs.passthru or { }) // {
      inherit updateScript;
    };
  })
