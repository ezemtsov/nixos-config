{ config, pkgs, ... }:

let
  status-bar = pkgs.writeShellScriptBin
    "status-bar" ./scripts/status-bar.sh;
in {
  systemd.user.services = {
    kbdd = {
      description = "Kbdd service";
      after       = [ "graphical-session-pre.target" ];
      partOf      = [ "graphical-session.target" ];
      wantedBy    = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "forking";
        Restart = "always";
        RestartSec = 2;
        ExecStart = "${pkgs.kbdd}/bin/kbdd";
      };
    };
  };
}
