{ lib, stdenv, fetchFromGitHub, fetchurl, ant, unzip, makeWrapper, jdk, javaPackages, rsync, ffmpeg, batik, gsettings-desktop-schemas, xorg, wrapGAppsHook }:
let
  vaqua = fetchurl {
    name = "VAqua9.jar";
    url = "https://violetlib.org/release/vaqua/9/VAqua9.jar";
    sha256 = "cd0b82df8e7434c902ec873364bf3e9a3e6bef8b59cbf42433130d71bf1a779c";
  };

  jna = fetchurl {
    name = "jna-5.10.0.zip";
    url = "https://github.com/java-native-access/jna/archive/5.10.0.zip";
    sha256 = "B5CakOQ8225xNsk2TMV8CbK3RcsLlb+pHzjaY5JNwg0=";
  };

  flatlaf = fetchurl {
    name = "flatlaf-2.4.jar";
    url = "https://repo1.maven.org/maven2/com/formdev/flatlaf/2.4/flatlaf-2.4.jar";
    sha256 = "NVMYiCd+koNCJ6X3EiRx1Aj+T5uAMSJ9juMmB5Os+zc=";
  };

in
stdenv.mkDerivation rec {
  pname = "processing";
  version = "1286-4.0.1";

  src = fetchFromGitHub {
    owner = "processing";
    repo = "processing4";
    rev = "processing-${version}";
    sha256 = "sha256-U6qYHpkf7yCWnrl0GfDGgIrCN62AyNarRy/A1iUDlUQ=";
  };

  nativeBuildInputs = [ ant unzip makeWrapper wrapGAppsHook ];
  buildInputs = [ jdk javaPackages.jogl_2_3_2 ant rsync ffmpeg batik ];

  dontWrapGApps = true;

  buildPhase = ''
    echo "tarring jdk"
    tar --checkpoint=10000 -czf build/linux/jdk-17.0.4-amd64.tgz ${jdk}
    cp ${ant}/lib/ant/lib/{ant.jar,ant-launcher.jar} app/lib/
    mkdir -p core/library
    ln -s ${javaPackages.jogl_2_3_2}/share/java/* core/library/
    cp ${vaqua} app/lib/VAqua9.jar
    cp ${flatlaf} app/lib/flatlaf.jar
    unzip -qo ${jna} -d app/lib/
    mv app/lib/{jna-5.10.0/dist/jna.jar,}
    mv app/lib/{jna-5.10.0/dist/jna-platform.jar,}
    cp -r ${batik}/* java/libraries/svg/library/
    cp java/libraries/svg/library/lib/batik-all-1.14.jar java/libraries/svg/library/batik.jar
    echo "tarring ffmpeg"
    tar --checkpoint=10000 -czf build/shared/tools/MovieMaker/ffmpeg-5.0.1.gz ${ffmpeg}
    cd build
    ant build
    cd ..
  '';

  installPhase = ''
    mkdir $out
    cp -dpr build/linux/work $out/${pname}
    rmdir $out/${pname}/java
    ln -s ${jdk} $out/${pname}/java
    makeWrapper $out/${pname}/processing      $out/bin/processing \
      ''${gappsWrapperArgs[@]} \
      --prefix _JAVA_OPTIONS " " -Dawt.useSystemAAFontSettings=lcd
    makeWrapper $out/${pname}/processing-java $out/bin/processing-java \
      ''${gappsWrapperArgs[@]} \
      --prefix _JAVA_OPTIONS " " -Dawt.useSystemAAFontSettings=lcd
  '';

  meta = with lib; {
    description = "A language and IDE for electronic arts";
    homepage = "https://processing.org";
    license = with licenses; [ gpl2Only lgpl21Only ];
    platforms = platforms.linux;
    maintainers = with maintainers; [  ];
  };
}
