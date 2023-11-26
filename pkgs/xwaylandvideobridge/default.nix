{ inputs
, stdenv
, fetchFromGitLab
, cmake
, pkg-config
, extra-cmake-modules
, qt5
, libsForQt5
}: qt5.mkDerivation rec {
  pname = "xwaylandvideobridge";
  version = "unstable-2023-09-27";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "system";
    repo = "xwaylandvideobridge";
    rev = "58541fa208ec93407c0df1e65a32933c67c83531";
    hash = "sha256-1SRK08wijzoPE4hLBxBexSEVrA8HOGKbPkLrF6qHFpY=";
  };

  patches = [ ../../patches/xwaylandvideobridge.diff ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    pkg-config
  ];

  buildInputs = [
    qt5.qtbase
    qt5.qtquickcontrols2
    qt5.qtx11extras
    libsForQt5.kdelibs4support
    (libsForQt5.kpipewire.overrideAttrs (oldAttrs: {
      version = "unstable-2023-09-27";

      src = fetchFromGitLab {
        domain = "invent.kde.org";
        owner = "plasma";
        repo = "kpipewire";
        rev = "Plasma/5.27";
        hash = "sha256-9A5UucBEMRWdzKFOdYqcuxM2f7Vyvw+Ke0qPwoK5R2c=";
      };
    }))
  ];

  # dontWrapQtApps = true;
}
