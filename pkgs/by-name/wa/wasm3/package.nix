{
  lib,
  stdenv,
  cmake,
  fetchFromGitHub,
  python3,
}:

stdenv.mkDerivation rec {
  pname = "wasm3";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "wasm3";
    repo = "wasm3";
    tag = "v${version}";
    hash = "sha256-0LFsyAhT51rhXORnxMQ8/Jt22F6neE5aZZSxF5c7HBw=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail " -fno-stack-check -fno-stack-protector" ""
  '';

  nativeBuildInputs = [ cmake ];

  nativeCheckInputs = [ python3 ];

  cmakeFlags = [
    "-DBUILD_NATIVE=OFF"
    "-DBUILD_WASI=simple"
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  checkPhase = ''
    runHook preCheck

    pushd ../test
    python3 run-regression-test.py
    python3 run-wasi-test.py
    python3 test_nan_propagation.py ../build/wasm3
    popd

    runHook postCheck
  '';

  meta = {
    homepage = "https://github.com/wasm3/wasm3";
    description = "Fastest WebAssembly interpreter, and the most universal runtime";
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ malbarbo ];
    license = lib.licenses.mit;
    knownVulnerabilities = [
      # The validator mitigates malformed inputs for these issues, but
      # upstream has no CVE-specific fix confirmation and the underlying
      # paths remain reachable or their original reproducers are unavailable.
      "CVE-2024-27528"
      "CVE-2024-27527"
      "CVE-2022-34529"
      "CVE-2022-39974"
      "CVE-2021-45947"
    ];
  };
}
