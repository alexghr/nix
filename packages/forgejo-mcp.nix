{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "forgejo-mcp";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "goern";
    repo = "forgejo-mcp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-V/8+/sJT8ZCzlSQE2POm4CKhpTqYmduhn1WVqbHrOe8=";
  };

  vendorHash = "sha256-pz0K4AMoUJjbVjVjOI9mbR1P+8rolehijF1x+3YP6VI=";

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
