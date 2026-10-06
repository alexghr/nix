{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "forgejo-mcp";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "goern";
    repo = "forgejo-mcp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dZ7k2c0abejHuwdRkXcOMKCnDeY193PYkIg0LVzbvII=";
  };

  vendorHash = "sha256-3RFWaohlUd6RpU531/DQH5wgVtjOi/Lh19Hyget7Bhw=";

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
