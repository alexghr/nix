# This file has been generated by node2nix 1.9.0. Do not edit!

{nodeEnv, fetchurl, fetchgit, nix-gitignore, stdenv, lib, globalBuildInputs ? []}:

let
  sources = {};
in
{
  yarn = nodeEnv.buildNodePackage {
    name = "yarn";
    packageName = "yarn";
    version = "1.22.17";
    src = fetchurl {
      url = "https://registry.npmjs.org/yarn/-/yarn-1.22.17.tgz";
      sha512 = "H0p241BXaH0UN9IeH//RT82tl5PfNraVpSpEoW+ET7lmopNC61eZ+A+IDvU8FM6Go5vx162SncDL8J1ZjRBriQ==";
    };
    buildInputs = globalBuildInputs;
    meta = {
      description = "📦🐈 Fast, reliable, and secure dependency management.";
      homepage = "https://github.com/yarnpkg/yarn#readme";
      license = "BSD-2-Clause";
    };
    production = true;
    bypassCache = true;
    reconstructLock = true;
  };
}
