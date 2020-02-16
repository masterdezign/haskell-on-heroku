let
  nixpkgs = (import ./nix/nixpkgs.nix);
in
  { busybox ? nixpkgs.busybox
  , callPackage ? nixpkgs.callPackage
  , dockerTools ? nixpkgs.dockerTools
  , haskell ? nixpkgs.haskell
  , lib ? nixpkgs.lib
  , ...
  }:
  let
    package = lib.pipe (callPackage ./. {}) (with haskell.lib; [
      dontCheck
      disableSharedLibraries
      justStaticExecutables
    ]);
  in
    nixpkgs.dockerTools.buildImage {
      name = package.pname;
      tag = "latest";
      contents = [
        busybox
        package
      ];
      config = {
        Cmd = ["/bin/${package.pname}"];
      };
    }
