{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.cockpit;
  cockpit = pkgs.callPackage ./default.nix {};
in {
  options.services.cockpit.enable = mkEnableOption "cockpit linux server gui";

  config = mkIf cfg.enable {
    # users.groups.cockpit-ws = {};
    # users.groups.cockpit-wsinstance = {};

    # users.users.cockpit-ws = {
    #   isSystemUser = true;
    #   group = "cockpit-ws";
    #   extraGroups = ["utmp" "shadow" "root"];
    #   description = "User for cockpit web service";
    # };

    # users.users.cockpit-wsinstance = {
    #   isSystemUser = true;
    #   group = "cockpit-wsinstance";
    #   extraGroups = ["utmp" "shadow" "root"];
    #   description = "User for cockpit-ws instances";
    # };

    systemd.packages = with  pkgs; [ cockpit packagekit ];

    environment.systemPackages = with pkgs; [ cockpit packagekit selinux-python ];
        
    environment.pathsToLink = [ "/share/cockpit" "/share/locale" "/share/polkit-1/actions" ];

    security.pam.services.cockpit.text = ''
      # Account management.
      account required pam_nologin.so
      account required pam_unix.so
      
      # Authentication management.
      # this MUST be first in the "auth" stack as it sets PAM_USER
      # user_unknown is definitive, so die instead of ignore to avoid subsequent modules mess up the error code
      -auth [success=done new_authtok_reqd=done user_unknown=die default=ignore] ${cockpit}/lib/security/pam_cockpit_cert.so
      auth sufficient pam_unix.so likeauth try_first_pass
      auth sufficient pam_rootok.so
      auth optional   ${cockpit}/lib/security/pam_ssh_add.so
      auth required   pam_deny.so
      
      # Password management.
      password sufficient pam_unix.so nullok sha512
      
      # Session management.
      session optional pam_keyinit.so force revoke
      session optional ${cockpit}/lib/security/pam_ssh_add.so
      
      session required pam_env.so conffile=/etc/pam/environment readenv=0
      session required pam_unix.so
      session optional pam_loginuid.so
      # session required ${pkgs.linux-pam}/lib/security/pam_lastlog.so silent
      # session optional ${pkgs.systemd}/lib/security/pam_systemd.so
    '';
  };
}
