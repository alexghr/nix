{...}: {
  perSystem = {
    system,
    pkgs,
    ...
  }: let
    socat = pkgs.dockerTools.buildImage {
      name = "socat-tunnel";
      tag = "latest";
      
      copyToRoot = pkgs.buildEnv {
        name = "image-root";
        paths = [ pkgs.socat pkgs.bash pkgs.coreutils ];
        pathsToLink = [ "/bin" ];
      };

      config = {
        Cmd = [ 
          "${pkgs.bash}/bin/bash"
          "-c"
          ''
            LOCAL_PORT=''${LOCAL_PORT:-8080}
            REMOTE_HOST=''${REMOTE_HOST:-example.com}
            REMOTE_PORT=''${REMOTE_PORT:-443}
            USE_SSL=''${USE_SSL:-true}
            
            echo "Starting socat tunnel..."
            echo "Listening on 0.0.0.0:$LOCAL_PORT"
            echo "Forwarding to $REMOTE_HOST:$REMOTE_PORT (SSL: $USE_SSL)"
            
            if [ "$USE_SSL" = "true" ]; then
              exec ${pkgs.socat}/bin/socat \
                TCP-LISTEN:$LOCAL_PORT,fork,bind=0.0.0.0,reuseaddr \
                OPENSSL:$REMOTE_HOST:$REMOTE_PORT,verify=0
            else
              exec ${pkgs.socat}/bin/socat \
                TCP-LISTEN:$LOCAL_PORT,fork,bind=0.0.0.0,reuseaddr \
                TCP:$REMOTE_HOST:$REMOTE_PORT
            fi
          ''
        ];
        ExposedPorts = {
          "8545/tcp" = {};
        };
      };
    };
  in {
    packages.socat = socat;
  };
}
