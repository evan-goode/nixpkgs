{ lib
, stdenv
, buildPythonPackage
, fetchPypi
, pythonOlder

# Build dependencies
, setuptools

# Runtime dependencies
, appnope
, backcall
, decorator
, exceptiongroup
, jedi
, matplotlib-inline
, pexpect
, pickleshare
, prompt-toolkit
, pygments
, stack-data
, traitlets
, typing-extensions

# Test dependencies
, pytestCheckHook
, testpath
}:

buildPythonPackage rec {
  pname = "ipython";
  version = "8.20.0";
  pyproject = true;
  disabled = pythonOlder "3.10";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-LyG9P8HVFVDInuOUSuBLvHvHnhKeoJN9pubGi/2/EXo=";
  };

  nativeBuildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [
    backcall
    decorator
    jedi
    matplotlib-inline
    pexpect
    pickleshare
    prompt-toolkit
    pygments
    stack-data
    traitlets
  ] ++ lib.optionals (pythonOlder "3.11") [
    exceptiongroup
  ] ++ lib.optionals (pythonOlder "3.10") [
    typing-extensions
  ] ++ lib.optionals stdenv.isDarwin [
    appnope
  ];

  pythonImportsCheck = [
    "IPython"
  ];

  preCheck = ''
    export HOME=$TMPDIR

    # doctests try to fetch an image from the internet
    substituteInPlace pyproject.toml \
      --replace '"--ipdoctest-modules",' '"--ipdoctest-modules", "--ignore=IPython/core/display.py",'
  '';

  nativeCheckInputs = [
    pytestCheckHook
    testpath
  ];

  disabledTests = [
    # UnboundLocalError: local variable 'child' referenced before assignment
    "test_system_interrupt"
  ] ++ lib.optionals (stdenv.isDarwin) [
    # FileNotFoundError: [Errno 2] No such file or directory: 'pbpaste'
    "test_clipboard_get"
  ];

  meta = with lib; {
    description = "IPython: Productive Interactive Computing";
    downloadPage = "https://github.com/ipython/ipython/";
    homepage = "https://ipython.org/";
    changelog = "https://github.com/ipython/ipython/blob/${version}/docs/source/whatsnew/version${lib.versions.major version}.rst";
    license = licenses.bsd3;
    maintainers = with maintainers; [ bjornfor fridh ];
  };
}
