{ lib, stdenv
, fetchFromGitHub
, cdson
, clamav
, cunit
, mandoc
, curl
, ninja
, glibc
, elfutils
, file
, gettext
, elf-header
, gnumake
, icu
, json_c
, kmod
, libarchive
, libcap
, libxml2
, libyaml
, meson
, openssl
, perl
, pkgconfig
, rpm
, xmlrpc_c
, python3
, zlib
}:

stdenv.mkDerivation rec {
  pname = "rpminspect";
  version = "1.11";
  # src = fetchFromGitHub {
  #   owner = "rpminspect";
  #   repo = pname;
  #   rev = "v${version}";
  #   sha256 = "sha256-Fl0diB8nIgcszHFhr4arvmM7mWTFEQwD+CDgqTS3OlQ=";
  # };
  src = ~/git/rpminspect;

  #TODO some of these are runtime dependencies (nativeBuildInputs)
  buildInputs = [
    meson gnumake pkgconfig perl gettext json_c xmlrpc_c libxml2 rpm libarchive elfutils kmod zlib mandoc libyaml file openssl libcap icu curl gettext cunit cdson ninja
  ];

  nativeBuildInputs = [
    clamav
  ];

  ELF_H_PATH = "${glibc.dev}/include/elf.h";

  # mesonFlags = [
  #   "-Denable-annocheck=false"
  # ];

  preConfigure = ''
    export LIBRARY_PATH="${lib.makeLibraryPath buildInputs}"
  '';

  doCheck = true;
  checkInputs = [
    (python3.withPackages (ps: with ps; [
      rpm rpmfluff setuptools pyyaml
    ]))
  ];

  meta = with lib; {
  description = "Tool for inspecting RPM packages for common issues.";
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ evan-goode ];
  };
}
