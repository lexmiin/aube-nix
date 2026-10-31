{
  lib,
  stdenvNoCC,
  fetchurl,
  installShellFiles,
}: let
  releases = {
    aarch64-darwin = {
      target = "aarch64-apple-darwin";
      hash = "sha256-dMIlNZJ8js0cqZNzcenM5AprSueRXqXkXP/xfrXa1f8=";
    };
    aarch64-linux = {
      target = "aarch64-unknown-linux-musl";
      hash = "sha256-nOED/zbUMA1ftKCHMj25k1sYQ7xT32BC4DV7CYB+6dI=";
    };
    x86_64-linux = {
      target = "x86_64-unknown-linux-musl";
      hash = "sha256-lO6EjK63czJd4s5B7K7fRGDzdtlWuegU0h/Oki+YQtI=";
    };
  };
in
  stdenvNoCC.mkDerivation rec {
    pname = "aube";
    version = "2.8.5";

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
