# Fetch a single blob (usually an image layer) from an OCI registry.
# A blob's digest is the sha256 of its bytes, so it doubles as the
# fixed-output hash: the pin is exactly what the registry publishes.
{
  lib,
  stdenvNoCC,
  curl,
  jq,
  cacert,
}:

{
  registry,
  repository,
  digest,
  name ? "oci-blob",
}:

stdenvNoCC.mkDerivation {
  inherit name;
  nativeBuildInputs = [
    curl
    jq
  ];

  SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
  impureEnvVars = lib.fetchers.proxyImpureEnvVars;

  outputHashAlgo = "sha256";
  outputHashMode = "flat";
  outputHash = lib.removePrefix "sha256:" digest;

  buildCommand = ''
    # Anonymous pull token, discovered from the registry's auth challenge.
    # (GET, not HEAD: ghcr.io answers HEAD /v2/ with 405 and no challenge.)
    challenge=$(curl -sS -o /dev/null -D - "https://${registry}/v2/" | tr -d '\r' | grep -i '^www-authenticate:')
    realm=$(sed -n 's/.*realm="\([^"]*\)".*/\1/p' <<<"$challenge")
    service=$(sed -n 's/.*service="\([^"]*\)".*/\1/p' <<<"$challenge")
    token=$(curl -fsSL "$realm?service=$service&scope=repository:${repository}:pull" | jq -r .token)

    curl -fSL --retry 3 -H "Authorization: Bearer $token" -o "$out" \
      "https://${registry}/v2/${repository}/blobs/${digest}"
  '';
}
