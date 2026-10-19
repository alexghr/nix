{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "forgejo-mcp";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "goern";
    repo = "forgejo-mcp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mUrNSPtL2ac2et9r2O+4PmfDYjTX5nbOI/tZJG2UDEE=";
  };

  vendorHash = "sha256-Xj9fGiuSNYWtNzV8pQgpEr1HyqPDpac0ZpZD5SfKfFU=";

  ldflags = ["-s" "-X main.Version=${finalAttrs.version}"];

  __darwinAllowLocalNetworking = true;
  nativeInstallCheckInputs = [versionCheckHook];
  doInstallCheck = true;

  meta = {
    description = "Model Context Protocol server for the Forgejo REST API";
    homepage = "https://git.b4mad.industries/agentic-forges/forgejo-mcp";
    license = lib.licenses.gpl3Plus;
    mainProgram = "forgejo-mcp";
  };
})
