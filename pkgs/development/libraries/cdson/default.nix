{ lib, stdenv, fetchFromGitHub, meson, ninja }:

stdenv.mkDerivation rec {
  name = "cdson";

  src = fetchFromGitHub {
    owner = "evan-goode";
    repo = "cdson";
    rev = "main";
    sha256 = "sha256-AnwfuI1tdhmxmq1F7jB2Fef7JMFkOQH5P3W+bl38ttA=";
  };

  nativeBuildInputs = [ meson ninja ];

  outputs = ["out" "dev"];

  meta = with lib; {
    description = "C library for the DSON data serialization format, for humans";
    longDescription = ''
      A pure C parsing and serialization library for the DSON data serialization format, for humans. cdson is believed to have complete spec coverage, though as with any project, there may still be bugs.
    '';
    homepage    = "https://github.com/frozencemetery/cdson";
    maintainers = with maintainers; [ evan-goode ];
    platforms   = platforms.unix;
    license = licenses.mpl20;
  };
}
