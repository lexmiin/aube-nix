{
  lib,
  stdenvNoCC,
  fetchurl,
  installShellFiles,
  makeWrapper,
  usage,
}: let
  releases = {
    aarch64-darwin = {
      target = "aarch64-apple-darwin";
      hash = "sha256-d6najdBY9jSjHaXWstK6KK9YIiTovg79FPpjWyjyh5U=";
    };
    aarch64-linux = {
      target = "aarch64-unknown-linux-musl";
      hash = "sha256-+VEGB3mMBFvuQ0kZJA30Hk7wyVHvyNQ452Wy+92nDt0=";
    };
    x86_64-linux = {
      target = "x86_64-unknown-linux-musl";
      hash = "sha256-S/AGjNIl7Jjugwf12iS1I+5sYRXVLu9prdZfaqRxY9g=";
    };
  };
in
  stdenvNoCC.mkDerivation rec {
    pname = "aube";
    version = "1.31.0";

    src = let
      system = stdenvNoCC.hostPlatform.system;
      release =
        releases.${system}
        or (throw "aube-nix: unsupported system ${system}");
    in
      fetchurl {
        url = "https://github.com/jdx/aube/releases/download/v${version}/aube-v${version}-${release.target}.tar.gz";
        inherit (release) hash;
      };

    nativeBuildInputs = [
      installShellFiles
      makeWrapper
    ];

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall

      install -Dm755 aube $out/bin/aube
      install -Dm755 aubr $out/bin/aubr
      install -Dm755 aubx $out/bin/aubx

      for bin in aube aubr aubx; do
        wrapProgram $out/bin/$bin \
          --prefix PATH : "${lib.makeBinPath [usage]}"
      done

      $out/bin/aube completion bash > aube.bash
      $out/bin/aube completion fish > aube.fish
      $out/bin/aube completion zsh > _aube

      substituteInPlace aube.bash aube.fish _aube \
        --replace-fail '-p usage' '-p ${lib.getExe usage}' \
        --replace-fail 'usage complete-word' '${lib.getExe usage} complete-word'

      installShellCompletion --cmd aube \
        --bash aube.bash \
        --fish aube.fish \
        --zsh _aube

      runHook postInstall
    '';

    meta = {
      description = "Fast Node.js package manager";
      homepage = "https://github.com/jdx/aube";
      license = lib.licenses.mit;
      mainProgram = "aube";
      platforms = builtins.attrNames releases;
    };
  }
