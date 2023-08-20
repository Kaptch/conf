{ inputs
, lib
, stdenv
, fetchurl
, testVersion
, package
}:

stdenv.mkDerivation rec {
  pname = "package";

  src = fetchurl {
    url = null;
    sha256 = null;
  };
}
