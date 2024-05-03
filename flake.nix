{
  description = "DeepMind's AI Safety Gridworlds.";
  inputs = {
    gridworlds-src = {
      flake = false;
      url = "github:google-deepmind/ai-safety-gridworlds";
    };
    pycolab-src = {
      flake = false;
      url = "github:google-deepmind/pycolab";
    };
  };
  outputs =
    {
      gridworlds-src,
      pycolab-src,
      self,
    }:
    let
      pname = "ai-safety-gridworlds";
      pyname = "ai_safety_gridworlds";
      version = "0.0.1";
      src = gridworlds-src;
      pycolab =
        py:
        py.buildPythonPackage {
          pname = "pycolab";
          version = "1.0.0";
          src = pycolab-src;
          doCheck = false;
        };
      default-pkgs =
        p: py:
        with py;
        [
          absl-py
          numpy
        ]
        ++ [ (pycolab py) ];
      lookup-pkg-sets =
        ps: p: py:
        builtins.concatMap (f: f p py) ps;
    in
    {
      lib.with-pkgs =
        pkgs: pypkgs:
        pkgs.stdenv.mkDerivation {
          inherit pname version src;
          propagatedBuildInputs = lookup-pkg-sets [ default-pkgs ] pkgs pypkgs;
          buildPhase = ":";
          installPhase = ''
            mkdir -p $out/${pypkgs.python.sitePackages}
            mv ./${pyname} $out/${pypkgs.python.sitePackages}/${pyname}
          '';
        };
    };
}
