{ lib , llvmPackages_11 , cmake }:

llvmPackages_11.stdenv.mkDerivation {
  pname = "TEMPLATE - CHANGE_ME";
  version = "0.0.1";

  src = ./.;

  nativeBuildInputs = [ cmake ];
  buildInputs = [ ]; # Compile + runtime dependencies go here

  cmakeFlags = [
    "-DENABLE_TESTING=OFF"
    "-DENABLE_INSTALL=ON"
  ];

  meta = with lib; {
    homepage = "https://github.com/MeKot/nix-cpp-template.git";
    description = ''
      Nix + CMake cpp template
    '';
    licencse = licenses.mit;
    platforms = with platforms; linux ++ darwin;
    maintainers = [ ];
  };
}
