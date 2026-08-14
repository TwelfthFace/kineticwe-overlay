# KineticWE Gentoo Overlay

This repository provides a Gentoo Portage overlay containing the ebuilds required to install **KineticWE**.

KineticWE is a standalone Wayland compositor based on KWin, focused on providing native tiling window management without requiring the full KDE Plasma desktop.

## Installation

### Using `eselect-repository`

```sh
sudo emerge --ask app-eselect/eselect-repository dev-vcs/git

sudo eselect repository add kineticwe-overlay git https://github.com/TwelfthFace/kineticwe-overlay.git

sudo emaint sync -r kineticwe-overlay

sudo emerge --ask kde-plasma/kineticwe
```

Alternatively, clone this repository into your local Portage overlays and configure it as a standard custom repository.

### Stock Plasma compatibility

KineticWE is installed with a private runtime under `/opt/kineticwe`. Its session launcher intentionally exports private library, Qt plugin, QML, and data paths required by KineticWE.

Because the systemd user manager may persist across graphical sessions, these environment variables can otherwise remain present after leaving KineticWE and contaminate a subsequently started stock Plasma session. This can cause stock KWin plugins such as `screenshot`, `screencast`, and `eis` to be rejected with `mismatching plugin version` errors.

When the `plasma-clean-env` USE flag is enabled, an additional **Plasma (KineticWE sanitized)** session is installed. Use this session when switching from KineticWE back to stock Plasma. It removes the KineticWE-specific runtime environment before starting Plasma while leaving KineticWE's own `/opt/kineticwe` runtime unchanged.

The normal KineticWE session should continue to be launched through its provided session entry; do not globally remove the `/opt/kineticwe` runtime variables from the KineticWE launcher.

## Updating

To update the overlay:

```sh
sudo emaint sync -r kineticwe-overlay
```

Then update KineticWE as usual:

```sh
sudo emerge --ask --update kde-plasma/kineticwe
```

## Upstream Project

The KineticWE source code, documentation, and issue tracker are maintained in the main project repository:

https://gitlab.com/theblackdon/kineticwe

Please report bugs, request features, and contribute to the upstream project there.

Issues with the Gentoo ebuilds or packaging in this overlay should be reported to this repository instead.

