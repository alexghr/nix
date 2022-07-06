{ pkgs ? import <nixpkgs> {} }:

let
  githubSshKeys = { username, sha256 }:
    let
      url = "https://github.com/${username}.keys";
      response = builtins.readFile (pkgs.fetchurl { inherit sha256; inherit url; });
      lines = builtins.filter builtins.isString (builtins.split "\n" response);
      keys =  builtins.filter (s: builtins.stringLength s > 0) lines;
    in
      keys;
in
  githubSshKeys
