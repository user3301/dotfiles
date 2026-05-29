{ pkgs, lib, inputs, ... }:

{
  # nixos-wsl upstream Cargo.lock resolves systemd-journal-logger to 2.2.2
  # which has a flaky CDN on static.crates.io (intermittent 403).
  # This overrides the build to use 2.2.1 — same rustix 1.x deps, stable download.
  system.build.nativeUtils = lib.mkForce (pkgs.rustPlatform.buildRustPackage {
    pname = "nixos-wsl-utils";
    version = "1.0.0";

    src = "${inputs.nixos-wsl}/utils";
    cargoLock.lockFile = ./nixos-wsl-utils-cargo.lock;

    env = {
      NIXOS_WSL_SH = "${pkgs.bash}/bin/sh";
      NIXOS_WSL_ENV = "${pkgs.coreutils}/bin/env";
    };
  });
}
