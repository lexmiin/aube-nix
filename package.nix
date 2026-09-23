{
  lib,
  stdenvNoCC,
  fetchurl,
  installShellFiles,
}: let
  releases = {
    aarch64-darwin = {
      target = "aarch64-apple-darwin";
      hash = "sha256-cXY4wvuH4yMNhMVI7pUJ892ICWZ0RwLD4NA0Xxk3ybE=";
    };
    aarch64-linux = {
      target = "aarch64-unknown-linux-musl";
      hash = "sha256-l4J2g0EQBLvemlOy/39rX4PAEaAKg971VRFf0ahSa4U=";
    };
    x86_64-linux = {
      target = "x86_64-unknown-linux-musl";
      hash = "sha256-1wlo2zEM1Il1pF0v4mwOQ/wfio+Xtkff5NAhZhg8aqE=";
    };
  };
in
  stdenvNoCC.mkDerivation rec {
    pname = "aube";
    version = "2.3.0";

    src = let
      system = stdenvNoCC.hostPlatform.system;
      release =
        releases.${system}
        or (throw "aube-nix: unsupported system ${system}");
    in
      fetchurl {
        url = "https://github.com/aubepkg/aube/releases/download/v${version}/aube-v${version}-${release.target}.tar.gz";
        inherit (release) hash;
      };

    nativeBuildInputs = [installShellFiles];

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall

      install -Dm755 aube $out/bin/aube
      install -Dm755 aubr $out/bin/aubr
      install -Dm755 aubx $out/bin/aubx

      $out/bin/aube completion bash > aube.bash
      $out/bin/aube completion fish > aube.fish
      $out/bin/aube completion zsh > _aube

      installShellCompletion --cmd aube \
        --bash aube.bash \
        --fish aube.fish \
        --zsh _aube

      runHook postInstall
    '';

    meta = {
      description = "Fast Node.js package manager";
      homepage = "https://github.com/aubepkg/aube";
      license = lib.licenses.mit;
      mainProgram = "aube";
      platforms = builtins.attrNames releases;
    };
  }
