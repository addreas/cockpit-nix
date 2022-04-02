# Cockpit nix module (experimental/unmaintained)
Since the official release tarball contains pre-packaged web resources we can sidestep the issue of running webpack et. al. by just going for a `make install` in the build phase. 

Adding `module.nix` as an import, and `services.cockpit.enabled = true`  in `/etc/nixos/configuration.nix` should be enough to get started. 

# Seems to work
- Overview (except package updates link, usage history)
- Logs
- Account (only listing)
- Systemd services (not user)
- Terminal

# TODO
- [ ] networkmanager
- [ ] packagekit
- [ ] udisks2
- [ ] selinux
- [ ] cockpit-pcp (remove `--disable-pcp`, but first need to create package for https://github.com/performancecopilot/pcp)
- [ ] cockpit-podman (subpackage https://github.com/cockpit-project/cockpit-podman/)
- [ ] cockpit-machines (subpackage https://github.com/cockpit-project/cockpit-machines)
- [ ] don't run as root?
- [ ] nix flake
