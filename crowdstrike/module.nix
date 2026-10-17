{ config, lib, pkgs, ... }:

let
  falconSensor = pkgs.callPackage ./. { };
  cidSecret = ../secrets/crowdstrike-cid.age;
  hasCidSecret = builtins.pathExists cidSecret;
in
{
  age.secrets.crowdstrike-cid = lib.mkIf hasCidSecret {
    file = cidSecret;
    path = "/run/secrets/crowdstrike-cid";
    owner = "root";
    group = "root";
    mode = "0400";
  };

  environment.systemPackages = [ falconSensor ];

  systemd.packages = [ falconSensor.unwrapped ];

  systemd.tmpfiles.rules = falconSensor.tmpfilesRules;

  systemd.services.falcon-sensor-configure = lib.mkIf hasCidSecret {
    before = [ "falcon-sensor.service" ];
    after = [
      "agenix-install-secrets.service"
      "systemd-tmpfiles-setup.service"
    ];
    requiredBy = [ "falcon-sensor.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      cid="$(${pkgs.coreutils}/bin/tr -d '\n\r ' < ${config.age.secrets.crowdstrike-cid.path})"
      if [ -z "$cid" ]; then
        echo "CrowdStrike CID secret is empty" >&2
        exit 1
      fi

      /opt/CrowdStrike/falconctl -s --cid="$cid" -f
    '';
  };

  # Not wanted at boot: falcon-sensor-work-hours starts and stops it.
  systemd.services.falcon-sensor = lib.mkMerge [
    {
      after = [ "systemd-tmpfiles-setup.service" ];
    }

    (lib.mkIf hasCidSecret {
      after = [ "falcon-sensor-configure.service" ];
      requires = [ "falcon-sensor-configure.service" ];
    })

    (lib.mkIf (!hasCidSecret) {
      serviceConfig.ExecCondition = [ "/opt/CrowdStrike/falconctl -g --cid" ];
    })
  ];

  # Checked at boot and at each boundary, a missed one fires on resume.
  systemd.services.falcon-sensor-work-hours = {
    description = "Run the CrowdStrike Falcon Sensor only during work hours";
    wantedBy = [ "multi-user.target" ];
    after = [ "time-sync.target" ];
    startAt = [
      "Mon..Fri 08:00"
      "Mon..Fri 18:00"
    ];
    serviceConfig.Type = "oneshot";
    script = ''
      read -r day hour < <(date '+%u %H')
      action=stop
      if [ "$day" -le 5 ] && [ $((10#$hour)) -ge 8 ] && [ $((10#$hour)) -lt 18 ]; then
        action=start
      fi
      systemctl "$action" --no-block falcon-sensor.service
    '';
  };

  systemd.timers.falcon-sensor-work-hours.timerConfig.Persistent = true;
}
