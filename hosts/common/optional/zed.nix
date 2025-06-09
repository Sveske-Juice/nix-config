{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./services/msmtp.nix ];

  services.zfs.zed = {
    enableMail = true;
    settings = {
      ZED_DEBUG_LOG = "/tmp/zed.debug.log";
      ZED_NOTIFY_INTERVAL_SECS = 3600;
      ZED_NOTIFY_VERBOSE = true;

      ZED_USE_ENCLOSURE_LEDS = true;
      ZED_SCRUB_AFTER_RESILVER = true;

      ZED_SYSLOG_PRIORITY = "daemon.notice";
      ZED_SYSLOG_TAG = "zed";

      # Mail
      ZED_EMAIL_ADDR = [ "root" ]; # mail to root gets redirected
      ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/sendmail";
      ZED_EMAIL_OPTS = " @ADDRESS@";
    };
  };
}
