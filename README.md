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

