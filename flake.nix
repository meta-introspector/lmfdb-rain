{
  description = "Zone 42 Docking Station";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      
      zone42-dock = pkgs.python3Packages.buildPythonApplication {
        pname = "zone42-dock";
        version = "0.1.0";
        
        src = ./.;
        
        propagatedBuildInputs = with pkgs.python3Packages; [
          flask
          flask-cors
          polars
        ];
        
        format = "other";
        
        installPhase = ''
          mkdir -p $out/bin
          cp dock_server.py $out/bin/zone42-dock
          chmod +x $out/bin/zone42-dock
        '';
      };
    in {
      packages.${system}.default = zone42-dock;
      
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          python3
          python3Packages.flask
          python3Packages.flask-cors
          python3Packages.polars
        ];
        
        shellHook = ''
          echo "🚢 Zone 42 Docking Station Dev Environment"
          echo "Run: python3 dock_server.py"
        '';
      };
      
      apps.${system}.default = {
        type = "app";
        program = "${zone42-dock}/bin/zone42-dock";
      };
    };
}
