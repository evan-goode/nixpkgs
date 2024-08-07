{
  lib,
  buildPythonPackage,
  fetchFromSourcehut,

  # build-system
  setuptools,

  # dependencies
  pyusb,
  tqdm,
  zeroconf,

  # tests
  pillow,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pyatem";
  version = "0.11.0"; # check latest version in setup.py
  pyproject = true;

  src = fetchFromSourcehut {
    owner = "~martijnbraam";
    repo = "pyatem";
    rev = version;
    hash = "sha256-VBuOnUVB6n8ahVtunubgao9jHPu9ncX0dhDT0PdSFhU=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    pyusb
    tqdm
    zeroconf
  ];

  nativeCheckInputs = [
    pillow
    pytestCheckHook
  ];

  preCheck = ''
    TESTDIR=$(mktemp -d)
    cp -r pyatem/{test_*.py,fixtures} $TESTDIR/
    pushd $TESTDIR
  '';

  postCheck = ''
    popd
  '';

  pythonImportsCheck = [ "pyatem" ];

  meta = with lib; {
    description = "Library for controlling Blackmagic Design ATEM video mixers";
    homepage = "https://git.sr.ht/~martijnbraam/pyatem";
    license = licenses.lgpl3Only;
    maintainers = with maintainers; [ hexa ];
  };
}
