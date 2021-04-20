{ config, pkgs, ... }:

let
  status-bar = pkgs.writeShellScriptBin
    "status-bar" ./scripts/status-bar.sh;
in {
  # services.postgresql = {
  #   enable = true;
  #   package = pkgs.postgresql_11;
  #   enableTCPIP = true;
  #   authentication = pkgs.lib.mkOverride 10 ''
  #     local all all trust
  #     host all all ::1/128 trust
  #   '';
  #   initialScript = pkgs.writeText "backend-initScript" ''
  #     CREATE ROLE ezemtsov WITH LOGIN PASSWORD 'database' CREATEDB;
  #     CREATE DATABASE ezemtsov;
  #     GRANT ALL PRIVILEGES ON DATABASE ezemtsov TO ezemtsov;
  #   '';
  # };

  # enable status bar on start
  # environment.systemPackages = [ status-bar ];
  # systemd.user.services.status-bar = {
  #   description = "Status bar";
  #   after = [ "graphical-session-pre.target" ];
  #   partOf = [ "graphical-session.target" ];
  #   path = [ pkgs.bash
  #            pkgs.iw
  #            pkgs.xkblayout-state ];
  #   serviceConfig = {
  #     ExecStart = ''
  #     ${pkgs.bash}/bin/bash -c \
  #     "${status-bar}/bin/status-bar | \
  #     ${pkgs.dzen2}/bin/dzen2 -fn 'DejaVu Sans Mono:size=11' -p -dock -ta l -xs"
  #     '';
  #   };
  #   wantedBy = [ "graphical-session.target" ];
  # };

  systemd.user.services = {
    # feh = {
    #   description = "Set background";
    #   after = [ "graphical-session-pre.target" ];
    #   partOf = [ "graphical-session.target" ];
    #   serviceConfig = {
    #     Type = "simple";
    #     ExecStart = "${pkgs.feh}/feh --bg-color black";
    #     RestartSec = 3;
    #     Restart = "always";
    #   };
    #   wantedBy = [ "graphical-session.target" ];
    # };

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
        ExecStart = "${pkgs.dunst}/bin/dunst";
      };
    };

  };
}
