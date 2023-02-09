{ config, pkgs, ... }:

let
  status-bar = pkgs.writeShellScriptBin
    "status-bar" ./scripts/status-bar.sh;
in {
  services = {
    datadog-agent = {
      enable = false;
      enableTraceAgent = true;
      apiKeyFile = pkgs.writeText "datadog_api_key" "877548e15979cad623db1cf0115bb0ca";
      site = "datadoghq.eu";
    };
  };
  
  systemd.user.services = {

    clipit = {
      description = "Clipboard service";
      after       = [ "graphical-session-pre.target" ];
      partOf      = [ "graphical-session.target" ];
      wantedBy    = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = 2;
        ExecStart = "${pkgs.clipit}/bin/clipit";
      };
    };

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

    dunst = {
      description = "Notification service";
      after       = [ "graphical-session-pre.target" ];
      partOf      = [ "graphical-session.target" ];
      wantedBy    = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = 2;
        ExecStart = "${pkgs.dunst}/bin/dunst";
      };
    };

    flameshot = {
      description = "Screenshot service";
      after       = [ "graphical-session-pre.target" ];
      partOf      = [ "graphical-session.target" ];
      wantedBy    = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = 2;
        ExecStart = "${pkgs.flameshot}/bin/flameshot";
      };
    };
  };
}
