{ config, lib, pkgs, ... }:

with lib;
let cfg = config.services.evdevremapkeys;

in
{
  options.services.evdevremapkeys = {
    enable = mkEnableOption (lib.mdDoc ''evdevremapkeys'');

    settings = mkOption {
      type = (pkgs.formats.yaml { }).type;
      default = { };
      description = lib.mdDoc ''
        config.yaml for evdevremapkeys
      '';
    };
  };

  config = mkIf cfg.enable {
    boot.kernelModules = [ "uinput" ];
    services.udev.extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="input"
    '';
    users.groups.evdevremapkeys = { };
    users.users.evdevremapkeys = {
      description = "evdevremapkeys service user";
      group = "evdevremapkeys";
      extraGroups = [ "input" ];
      isSystemUser = true;
    };
    systemd.services.evdevremapkeys = {
      description = "evdevremapkeys";
      wantedBy = [ "multi-user.target" ];
      serviceConfig =
        let
          format = pkgs.formats.yaml { };
          config = format.generate "config.yaml" cfg.config;
        in
        {
          ExecStart = "${pkgs.evdevremapkeys}/bin/evdevremapkeys --config-file ${config}";
          User = "evdevremapkeys";
          Group = "evdevremapkeys";
          StateDirectory = "evdevremapkeys";
          Restart = "always";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateNetwork = true;
          PrivateTmp = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectKernelTunables = true;
          ProtectSystem = true;
        };
    };
  };
}
