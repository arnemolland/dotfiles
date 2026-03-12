{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:

let
  pname = "openfang";
  version = "0.3.45";
in
rustPlatform.buildRustPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "RightNow-AI";
    repo = "openfang";
    tag = "v${version}";
    hash = "sha256-QXigCIpzvlXHXhx1YKrbU5irmqTwgSgsGTRuUqd+bUo=";
  };

  cargoHash = "sha256-GoQwmwB2pv0hE8hNUhCBMZ6iTNT/HzyOnuCbv+p3Eh4=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  # Only build the CLI binary (skip desktop/tauri crate).
  cargoBuildFlags = [ "--package" "openfang-cli" ];
  cargoTestFlags = [ "--package" "openfang-cli" ];

  meta = with lib; {
    description = "Open-source agentic AI platform — spawn, manage, and chat with LLM agents";
    homepage = "https://github.com/RightNow-AI/openfang";
    license = with licenses; [ asl20 mit ];
    platforms = platforms.linux;
    mainProgram = "openfang";
  };
}
