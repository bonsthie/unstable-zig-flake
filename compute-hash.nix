{ pkgs ? import <nixpkgs> {},
  jsonSha256 ? (let envHash = builtins.getEnv "JSON_SHA256";
                in if envHash == "" then "19gc20b5368zgzs4lhd2nf9v497inphcpd5ic8jv30x4gndrdnmr" else envHash)
}:

let
  zigIndexJson = builtins.fromJSON (
    builtins.readFile (builtins.fetchurl {
      url = "https://ziglang.org/download/index.json";
      sha256 = jsonSha256;
    })
  );

  updateShaSumPkgs = versionAttrs:
    builtins.mapAttrs (key: value:
      if builtins.isAttrs value && builtins.hasAttr "tarball" value
      then
        value // {
          shasum = builtins.convertHash {
            hash = value.shasum;
            toHashFormat = "nix32";
            hashAlgo = "sha256";
          };
        }
      else if builtins.isAttrs value
      then updateShaSumPkgs value
      else value
    ) versionAttrs;

  # only keep the master branch (unstable version)
  updatedJson = updateShaSumPkgs zigIndexJson.master;

in
  pkgs.writeText "zig-lock.json" (builtins.toJSON updatedJson)
