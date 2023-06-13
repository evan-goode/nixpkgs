{ lib
, buildPythonPackage
, fetchurl
, glibcLocales
, rpm
, systemRpm
}:

buildPythonPackage rec {
  pname = "rpmfluff";
  version = "0.6.2";

  # src = fetchurl {
  #   url = "https://releases.pagure.org/${pname}/${pname}-${version}.tar.xz";
  #   sha256 = "sha256-g6EP2p3a+yjdU/UWfT37gwybem5Tcn3FtrDGHYKr2gY=";
  # };

  src = /home/evan/git/rpmfluff;

  propagatedBuildInputs = [ rpm ];

  LC_ALL="en_US.utf-8";
  buildInputs = [ glibcLocales ];

  nativeBuildInputs = [ systemRpm ];

  doCheck = false;

  meta = with lib; {
    description = "lightweight way of building RPMs, and sabotaging them";
    homepage = "https://pagure.io/rpmfluff";
    license = licenses.gpl2;
    maintainers = with maintainers; [ disassembler ];
  };
}
