{
	packageOverrides = let ownNodePkgs = import ./npm {}; in
	 pkgs: with pkgs; {
		myPackages = pkgs.buildEnv {
			name = "my-packages";
			paths = [
				nodejs-16_x
				nodePackages.node2nix
				
			] ++ builtins.attrValues ownNodePkgs;
		};
	};
}

