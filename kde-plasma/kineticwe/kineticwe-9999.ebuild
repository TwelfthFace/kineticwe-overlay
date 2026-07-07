# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 multilib ninja-utils

DESCRIPTION="KineticWE - a tiling KWin Wayland compositor"
HOMEPAGE="https://gitlab.com/theblackdon/kineticwe"
LICENSE="GPL-2+ LGPL-2+ MIT BSD CC0-1.0"
SLOT="0"
KEYWORDS=""

KGA_REPO_URI="https://invent.kde.org/plasma/kglobalacceld.git"

QTMIN="6.10.0"
KFMIN="6.26.0"
PLASMA_MIN="6.7.0"

PREFIX="/opt/${PN}"

BDEPEND="
	dev-build/cmake
	dev-build/ninja
	dev-vcs/git
	virtual/pkgconfig
	dev-util/wayland-scanner
	dev-util/vulkan-headers
	>=kde-frameworks/extra-cmake-modules-${KFMIN}
"

COMMON_DEPEND="
	>=dev-qt/qtbase-${QTMIN}:6[dbus,gui,opengl,wayland,widgets]
	>=dev-qt/qtdeclarative-${QTMIN}:6
	>=dev-qt/qt5compat-${QTMIN}:6
	>=dev-qt/qtsvg-${QTMIN}:6
	>=dev-qt/qttools-${QTMIN}:6
	>=dev-qt/qtwayland-${QTMIN}:6

	>=kde-frameworks/kauth-${KFMIN}:6
	>=kde-frameworks/kcmutils-${KFMIN}:6
	>=kde-frameworks/kcolorscheme-${KFMIN}:6
	>=kde-frameworks/kconfig-${KFMIN}:6
	>=kde-frameworks/kcoreaddons-${KFMIN}:6
	>=kde-frameworks/kcrash-${KFMIN}:6
	>=kde-frameworks/kdbusaddons-${KFMIN}:6
	>=kde-frameworks/kdeclarative-${KFMIN}:6
	>=kde-frameworks/kded-${KFMIN}:6
	>=kde-frameworks/kglobalaccel-${KFMIN}:6
	>=kde-frameworks/kguiaddons-${KFMIN}:6
	>=kde-frameworks/ki18n-${KFMIN}:6
	>=kde-frameworks/kidletime-${KFMIN}:6
	>=kde-frameworks/kio-${KFMIN}:6
	>=kde-frameworks/kirigami-${KFMIN}:6
	>=kde-frameworks/kjobwidgets-${KFMIN}:6
	>=kde-frameworks/knewstuff-${KFMIN}:6
	>=kde-frameworks/knotifications-${KFMIN}:6
	>=kde-frameworks/kpackage-${KFMIN}:6
	>=kde-frameworks/krunner-${KFMIN}:6
	>=kde-frameworks/kservice-${KFMIN}:6
	>=kde-frameworks/ksvg-${KFMIN}:6
	>=kde-frameworks/kwidgetsaddons-${KFMIN}:6
	>=kde-frameworks/kwindowsystem-${KFMIN}:6
	>=kde-frameworks/kxmlgui-${KFMIN}:6

	>=kde-plasma/kdecoration-${PLASMA_MIN}:6
	>=kde-plasma/knighttime-${PLASMA_MIN}:6
	>=kde-plasma/kscreenlocker-${PLASMA_MIN}:6
	>=kde-plasma/kwayland-${PLASMA_MIN}:6
	>=kde-plasma/libplasma-${PLASMA_MIN}:6
	>=kde-plasma/plasma-activities-${PLASMA_MIN}:6
	>=dev-libs/plasma-wayland-protocols-1.21.0

	dev-libs/glib:2
	dev-libs/jemalloc
	dev-libs/libinput
	dev-libs/libxml2
	dev-libs/wayland
	>=dev-libs/wayland-protocols-1.48
	gnome-base/librsvg
	media-libs/fontconfig
	media-libs/freetype
	media-libs/harfbuzz
	media-libs/lcms
	media-libs/libcanberra
	media-libs/libdisplay-info
	media-libs/libepoxy
	media-libs/libglvnd
	media-libs/libqaccessibilityclient
	media-libs/libwebp
	media-libs/mesa
	media-libs/vulkan-loader
	media-video/pipewire
	net-misc/curl
	sci-libs/libqalculate
	sys-apps/hwdata
	sys-apps/systemd
	sys-auth/polkit
	sys-libs/pam
	virtual/libudev
	x11-libs/cairo
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/libxcvt
	x11-libs/pango
	x11-libs/xcb-util
	x11-libs/xcb-util-cursor
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-renderutil
	x11-libs/xcb-util-wm
"

DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}
	>=kde-plasma/aurorae-${PLASMA_MIN}:6
	>=kde-plasma/breeze-${PLASMA_MIN}:6
	>=kde-plasma/kscreen-${PLASMA_MIN}:6
	>=kde-plasma/milou-${PLASMA_MIN}:6
	>=kde-plasma/plasma-workspace-${PLASMA_MIN}:6
	>=kde-plasma/xdg-desktop-portal-kde-${PLASMA_MIN}:6
	sys-apps/xdg-desktop-portal
	x11-base/xwayland
"

src_unpack() {
	EGIT_REPO_URI="https://gitlab.com/theblackdon/kineticwe.git" \
	EGIT_CHECKOUT_DIR="${S}" \
		git-r3_src_unpack

	EGIT_REPO_URI="${KGA_REPO_URI}" \
	EGIT_CHECKOUT_DIR="${WORKDIR}/kglobalacceld" \
		git-r3_src_unpack
}

src_compile() {
	local libdir
	libdir="$(get_libdir)"

	local common_cmake_args=(
		-G Ninja
		-DCMAKE_INSTALL_PREFIX="${PREFIX}"
		-DCMAKE_INSTALL_LIBDIR="${libdir}"
		-DCMAKE_BUILD_TYPE=RelWithDebInfo
		-DBUILD_TESTING=OFF
	)

	einfo "Building bundled kglobalacceld into temporary staging prefix"
	cmake \
		-S "${WORKDIR}/kglobalacceld" \
		-B "${WORKDIR}/build-kglobalacceld" \
		"${common_cmake_args[@]}" \
		|| die "kglobalacceld configure failed"

	eninja -C "${WORKDIR}/build-kglobalacceld"

	DESTDIR="${WORKDIR}/kga-stage" \
		cmake --install "${WORKDIR}/build-kglobalacceld" \
		|| die "kglobalacceld staging install failed"

	einfo "Building KineticWE against staged kglobalacceld"
	cmake \
		-S "${S}" \
		-B "${WORKDIR}/build-kineticwe" \
		"${common_cmake_args[@]}" \
		-DCMAKE_PREFIX_PATH="${WORKDIR}/kga-stage${PREFIX}" \
		-DKWIN_BUILD_GLOBALSHORTCUTS=ON \
		-DKWIN_BUILD_X11=ON \
		|| die "kineticwe configure failed"

	eninja -C "${WORKDIR}/build-kineticwe"
}

src_install() {
	local libdir
	libdir="$(get_libdir)"

	DESTDIR="${D}" \
		cmake --install "${WORKDIR}/build-kglobalacceld" \
		|| die "kglobalacceld install failed"

	DESTDIR="${D}" \
		cmake --install "${WORKDIR}/build-kineticwe" \
		|| die "kineticwe install failed"

	rm -rf "${ED}${PREFIX}/include" || die
	rm -rf "${ED}${PREFIX}/${libdir}/cmake" || die
	find "${ED}${PREFIX}" -name '*.a' -delete || die
	rm -f "${ED}${PREFIX}/${libdir}/libKGlobalAccelD.so" || die
	rm -f "${ED}${PREFIX}/${libdir}/libkwin.so" || die
	rm -f "${ED}${PREFIX}/${libdir}/libkcmkwincommon.so" || die

	dodir "${PREFIX}/bin"

	cat > "${ED}${PREFIX}/bin/start-kineticwe" <<KINETICWE_LAUNCHER
#!/usr/bin/env bash
set -e

PREFIX="${PREFIX}"
LIBDIR="${libdir}"

export PREFIX
export LIBDIR

export PATH="\${PREFIX}/bin:\${PATH}"
export LD_LIBRARY_PATH="\${PREFIX}/\${LIBDIR}:\${PREFIX}/lib:\${LD_LIBRARY_PATH:-}"
export QT_PLUGIN_PATH="\${PREFIX}/\${LIBDIR}/qt6/plugins:\${PREFIX}/\${LIBDIR}/plugins:\${QT_PLUGIN_PATH:-}"
export QML2_IMPORT_PATH="\${PREFIX}/\${LIBDIR}/qt6/qml:\${PREFIX}/\${LIBDIR}/qml:\${QML2_IMPORT_PATH:-}"
export XDG_DATA_DIRS="\${PREFIX}/share:/usr/local/share:/usr/share\${XDG_DATA_DIRS:+:\${XDG_DATA_DIRS}}"

export XDG_CURRENT_DESKTOP=KDE
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=KDE
export KDE_SESSION_VERSION=6
export QT_QPA_PLATFORM=wayland
export XDG_MENU_PREFIX=plasma-

runtime_dir="\${XDG_RUNTIME_DIR:-/tmp}"
payload_dir="\${runtime_dir}/kineticwe-\${USER}"
mkdir -p "\${payload_dir}"

payload="\${payload_dir}/startup.sh"

cat > "\${payload}" <<'PAYLOAD'
#!/usr/bin/env bash

mkdir -p "\${HOME}/.local/share"

export XDG_CURRENT_DESKTOP=KDE
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=KDE
export KDE_SESSION_VERSION=6
export QT_QPA_PLATFORM=wayland
export XDG_MENU_PREFIX=plasma-

# Wait until KineticWE has created its Wayland socket.
runtime_dir="\${XDG_RUNTIME_DIR:-/run/user/\$(id -u)}"

if [[ -z "\${WAYLAND_DISPLAY:-}" ]]; then
	for socket in "\${runtime_dir}"/wayland-*; do
		if [[ -S "\${socket}" ]]; then
			export WAYLAND_DISPLAY="\${socket##*/}"
			break
		fi
	done
fi

for i in {1..100}; do
	if [[ -n "\${WAYLAND_DISPLAY:-}" &&
		-S "\${runtime_dir}/\${WAYLAND_DISPLAY}" ]]; then
			break
	fi

	sleep 0.05
done

if [[ -z "\${WAYLAND_DISPLAY:-}" ||
	! -S "\${runtime_dir}/\${WAYLAND_DISPLAY}" ]]; then
		echo "KineticWE Wayland socket not ready: WAYLAND_DISPLAY=\${WAYLAND_DISPLAY:-unset}" \
			> "\${HOME}/.local/share/kineticwe-wayland-wait.log"
	exit 0
fi

systemctl --user set-environment \\
	WAYLAND_DISPLAY="\${WAYLAND_DISPLAY}" \\
	DISPLAY="\${DISPLAY:-}" \\
	XAUTHORITY="\${XAUTHORITY:-}" \\
	XDG_CURRENT_DESKTOP=KDE \\
	XDG_SESSION_TYPE=wayland \\
	XDG_SESSION_DESKTOP=KDE \\
	KDE_SESSION_VERSION=6 \\
	QT_QPA_PLATFORM=wayland \\
	XDG_MENU_PREFIX=plasma- \\
	PATH="\${PATH}" \\
	LD_LIBRARY_PATH="\${LD_LIBRARY_PATH:-}" \\
	QT_PLUGIN_PATH="\${QT_PLUGIN_PATH:-}" \\
	QML2_IMPORT_PATH="\${QML2_IMPORT_PATH:-}" \\
	XDG_DATA_DIRS="\${XDG_DATA_DIRS:-}" 2>/dev/null || true

systemctl --user import-environment \\
	WAYLAND_DISPLAY \\
	DISPLAY \\
	XAUTHORITY \\
	XDG_CURRENT_DESKTOP \\
	XDG_SESSION_TYPE \\
	XDG_SESSION_DESKTOP \\
	KDE_SESSION_VERSION \\
	QT_QPA_PLATFORM \\
	XDG_MENU_PREFIX \\
	PATH \\
	LD_LIBRARY_PATH \\
	QT_PLUGIN_PATH \\
	QML2_IMPORT_PATH \\
	XDG_DATA_DIRS 2>/dev/null || true

dbus-update-activation-environment --systemd \\
	WAYLAND_DISPLAY \\
	DISPLAY \\
	XAUTHORITY \\
	XDG_CURRENT_DESKTOP \\
	XDG_SESSION_TYPE \\
	XDG_SESSION_DESKTOP \\
	KDE_SESSION_VERSION \\
	QT_QPA_PLATFORM \\
	XDG_MENU_PREFIX \\
	PATH \\
	LD_LIBRARY_PATH \\
	QT_PLUGIN_PATH \\
	QML2_IMPORT_PATH \\
	XDG_DATA_DIRS 2>/dev/null || true

if command -v kbuildsycoca6 >/dev/null 2>&1; then
	kbuildsycoca6 --noincremental >"\${HOME}/.local/share/kbuildsycoca6-kineticwe.log" 2>&1 || true
fi

for unit in \\
	plasma-kcminit.service \\
	plasma-kded6.service \\
	plasma-krunner.service \\
	plasma-polkit-agent.service \\
	plasma-powerdevil.service
do
	systemctl --user reset-failed "\${unit}" 2>/dev/null || true
	systemctl --user start "\${unit}" 2>/dev/null || true
done

systemctl --user reset-failed plasma-kactivitymanagerd.service 2>/dev/null || true
systemctl --user start plasma-kactivitymanagerd.service 2>/dev/null || true

if ! pgrep -u "\$(id -u)" -x kded6 >/dev/null 2>&1; then
	if command -v kded6 >/dev/null 2>&1; then
		nohup kded6 >"\${HOME}/.local/share/kded6-kineticwe.log" 2>&1 &
	fi
fi

find_portal() {
	local name="\$1"

	for path in \\
		"/usr/libexec/\${name}" \\
		"/usr/lib/\${name}" \\
		"\${PREFIX}/libexec/\${name}" \\
		"\${PREFIX}/\${LIBDIR}/libexec/\${name}"
	do
		if [[ -x "\${path}" ]]; then
			printf '%s\n' "\${path}"
			return 0
		fi
	done

	command -v "\${name}" 2>/dev/null || true
}

PORTAL_KDE="\$(find_portal xdg-desktop-portal-kde)"
PORTAL="\$(find_portal xdg-desktop-portal)"

killall -q xdg-desktop-portal-kde xdg-desktop-portal xdg-desktop-portal-gtk xdg-document-portal 2>/dev/null || true

if [[ -n "\${PORTAL_KDE}" && -x "\${PORTAL_KDE}" ]]; then
	nohup "\${PORTAL_KDE}" >"\${HOME}/.local/share/xdg-desktop-portal-kde.log" 2>&1 &
fi

sleep 1

if [[ -n "\${PORTAL}" && -x "\${PORTAL}" ]]; then
	nohup "\${PORTAL}" >"\${HOME}/.local/share/xdg-desktop-portal.log" 2>&1 &
fi

systemctl --user reset-failed plasma-krunner.service 2>/dev/null || true
systemctl --user start plasma-krunner.service 2>/dev/null || true

if command -v noctalia >/dev/null 2>&1; then
	nohup noctalia >"\${HOME}/.local/share/noctalia.log" 2>&1 &
elif command -v noctalia-shell >/dev/null 2>&1; then
	nohup noctalia-shell >"\${HOME}/.local/share/noctalia.log" 2>&1 &
else
	echo "Noctalia not found" >"\${HOME}/.local/share/noctalia.log"
fi
PAYLOAD

chmod +x "\${payload}"

systemctl --user stop plasma-kglobalaccel.service 2>/dev/null || true
pkill -x kglobalacceld 2>/dev/null || true

exec kinetic-we --xwayland "\${payload}"
KINETICWE_LAUNCHER

	fperms 0755 "${PREFIX}/bin/start-kineticwe"

	cat > "${T}/kineticwe.desktop" <<EOF
[Desktop Entry]
Name=KineticWE
Comment=A KWin Window Environment
Exec=${PREFIX}/bin/start-kineticwe
Type=Application
DesktopNames=KDE
EOF

	insinto /usr/share/wayland-sessions
	doins "${T}/kineticwe.desktop"

	dodoc README.md CONTRIBUTING.md || true
}

pkg_postinst() {
	elog "KineticWE has been installed side-by-side under ${PREFIX}."
	elog "A Wayland session entry was installed at /usr/share/wayland-sessions/kineticwe.desktop."
	elog "This package starts KineticWE and attempts to launch Noctalia plus required KDE user services."
	elog "If dependency resolution fails, you probably need newer Qt/KF/Plasma packages, likely ~amd64 or the KDE overlay."
}
