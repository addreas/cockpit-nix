{
  stdenv,
  lib,
  fetchgit,
  fetchzip,
  callPackage,
  makeWrapper,

  automake,
  autoreconfHook,
  git,
  nodejs,
  pkgconfig,
  python3,

  coreutils,
  gnused,
  systemd,
  openssl,
  openssh,
  dbus,
  keyutils,
  polkit,
  gtk-doc,
  json-glib,
  krb5,
  nfs-utils,
  pam_krb5,
  linux-pam,
  pam,
  libxslt,
  libssh,
  intltool,
  gobject-introspection,
  networkmanager,
  xmlto,
  nodePackages,
  perlPackages,
}:
stdenv.mkDerivation rec {
  pname = "cockpit";
  version = "265";

  src = fetchzip {
    url = "https://github.com/cockpit-project/cockpit/releases/download/${version}/cockpit-${version}.tar.xz";
    sha256 = "+eAN6aNLnGVHLnku7PfqyVd3iCIatN+BJgS3bWDfbZg=";
  };

  nativeBuildInputs = [
    automake
    git
    autoreconfHook
    pkgconfig
    python3
    makeWrapper
  ];

  buildInputs = [
    systemd
    dbus
    keyutils
    polkit
    gtk-doc
    json-glib
    krb5
    nfs-utils
    pam_krb5
    linux-pam
    libxslt
    libssh
    intltool
    gobject-introspection
    networkmanager
    xmlto
    perlPackages.JavaScriptMinifierXS
    perlPackages.FileShareDir
    perlPackages.JSON
  ];

  patches = [
    ./fix_paths.patch
  ];

  postPatch = ''
    patchShebangs tools

    substituteAllInPlace src/bridge/bridge.c
    substituteAllInPlace src/bridge/org.cockpit-project.cockpit-bridge.policy.in

    substituteAllInPlace src/session/session-utils.h
  
    coreutils=${coreutils} substituteAllInPlace src/systemd/cockpit.service.in
    substituteAllInPlace src/systemd/cockpit-wsinstance-http.service.in
    substituteAllInPlace src/systemd/cockpit-wsinstance-https-factory@.service.in
    substituteAllInPlace src/systemd/cockpit-wsinstance-https@.service.in
    gnused=${gnused} substituteAllInPlace src/systemd/update-motd

    openssh=${openssh} substituteAllInPlace src/pam-ssh-add/pam-ssh-add.c
  '';

  configureFlags = [
    "--disable-pcp"
    "--disable-doc"
    "--with-systemdunitdir=$(out)/etc/systemd/system"
    # "--with-cockpit-user=cockpit-ws"
    # "--with-cockpit-ws-instance-user=cockpit-wsinstance"
    "--enable-debug"
    "SSH_ADD=${openssh}/bin/ssh-add"
    "SSH_AGENT=${openssh}/bin/ssh-agent"
  ];

  buildPhase = ''
   ./tools/adjust-distdir-timestamps .

    make install
    '';

  postInstall = ''
    wrapProgram "$out/libexec/cockpit-certificate-helper" --suffix PATH : "${lib.makeBinPath [coreutils openssl]}"
    '';

  meta = with lib; {
    description = "A sysadmin login session in a web browser";
    homepage = "https://www.cockpit-project.org";
    license = licenses.lgpl2;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers;
      [
        thefenriswolf
        baronleonardo
      ];
  };
}
