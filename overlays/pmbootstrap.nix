{ inputs }:
final: prev: {
  pmbootstrap = prev.pmbootstrap.overrideAttrs (old: {
    pname = "pmbootstrap";
    version = "2.0.0";

    src = final.fetchPypi {
      pname = "pmbootstrap";
      version = "2.0.0";
      hash = "sha256-nN4KUP9l3g5Q+QeWr4Fju2GiOyu2f7u94hz/VJlCYdw=";
    };

    repo = final.fetchFromGitLab {
      domain = "gitlab.com";
      owner = "postmarketOS";
      repo = "pmbootstrap";
      rev = "2.0.0";
      hash = "sha256-UkgCNob4nazFO8xXyosV+11Sj4yveYBfgh7aw+/6Rlg=";
    };

    disabledTests = prev.pmbootstrap.disabledTests ++ [
      "test_build_abuild_leftovers"
      "test_get_all_component_names"
      "test_check_config"
      "test_extract_arch"
      "test_extract_version"
      "test_check"
    ];
  });
}
