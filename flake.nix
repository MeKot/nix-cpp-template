{
  description = "TEMPLATE - CHANGE_ME";

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, ... }@inputs: inputs.utils.lib.eachSystem [

    # Arch to support
    "x86_64-linux"
    # "i686-linux" "aarch64-linux" "x86_64-darwin"
  ] (system:
  let

    pkgs = import nixpkgs {
      inherit system;

      overlays = [];

      config.allowUnfree = true; # -- Check this if selling software
    };

  in {
    devShells.default = pkgs.mkShell rec {
      name = "TEMPLATE - CHANGE_ME";

      packages = with pkgs; [
        # Dev env
        llvmPackages_14.clang-unwrapped
        cmake
        cmakeCurses

        # Tests
        gtest

        # Compile time depenedencies
        abseil-cpp
      ];

      # A cool shell for kicks
      shellHook = let
        icon = "f121";
      in ''
        export PS1="$(echo -e '\u${icon}') {\[$(tput sgr0)\]\[\033[38;5;228m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\]} (${name}) \\$ \[$(tput sgr0)\]"
        export ENV_PROMPT_MODIFIER=" $(echo -e '\u${icon}') (${name})"
      '';
    };

    packages.default = pkgs.callPackage ./default.nix {};
  });
}
