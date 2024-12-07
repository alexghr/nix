# slightly modified version of the script at
# https://github.com/caarlos0/dotfiles/blob/e2cb05d1e381956b7aba4303cc27206695657a0e/packages/cachixe.nix
{...}: {
  perSystem = {
    system,
    pkgs,
    ...
  }: let
    uploadToCache = {
      cacheHost,
      sshUser ? "nix-ssh",
      writeShellScriptBin,
      hostname-debian,
      gnugrep,
      dig,
      iputils,
      openssh,
      ...
    }:
      writeShellScriptBin "upload-to-cache" ''
        if ! ${iputils}/bin/ping -c 1 ${cacheHost} &> /dev/null; then
          echo "${cacheHost} is unreachable. Skipping uploading to cache..."
          exit 0
        fi

        if ! ${openssh}/bin/ssh -T -f -q -o BatchMode=yes ${sshUser}@${cacheHost} true &> /dev/null; then
          echo "Can't ssh to ${cacheHost}. Skipping uploading to cache..."
          exit 0
        fi

        CACHE_IP="$(${dig}/bin/dig +short ${cacheHost})"
        MY_IPS="$(${hostname-debian}/bin/hostname -I)"

        if [ "$(echo $MY_IPS | ${gnugrep}/bin/grep $CACHE_IP)" ]; then
          # the current machine hosts the cache!
          exit 0
        fi

        set -eu
        set -f # disable globbing
        export IFS=' '
        echo "Uploading paths" $OUT_PATHS
        exec nix copy --to "ssh://${sshUser}@${cacheHost}" $OUT_PATHS
      '';
  in {
    packages.uploadToCache = pkgs.callPackage uploadToCache {cacheHost = "nixcache.esrever.uno";};
  };
}
