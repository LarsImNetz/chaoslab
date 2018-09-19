# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit desktop gnome2-utils

ELECTRON_SLOT="2.0"
DESCRIPTION="The graphical front-end for Sia"
HOMEPAGE="https://sia.tech"
SRC_URI="https://github.com/NebulousLabs/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=">=net-libs/nodejs-6.9.0"
RDEPEND="
	net-p2p/Sia
	dev-util/electron-bin:${ELECTRON_SLOT}
"

pkg_setup() {
	# shellcheck disable=SC2086
	if has network-sandbox $FEATURES; then
		ewarn
		ewarn "${CATEGORY}/${PN} requires 'network-sandbox' to be disabled in FEATURES"
		ewarn
		die "[network-sandbox] is enabled in FEATURES"
	fi
}

src_compile() {
	npm install || die
	npm run build || die
}

src_install() {
	newbin "${FILESDIR}"/Sia-UI-launcher.sh sia-ui
	sed "s:%%ELECTRON%%:electron-${ELECTRON_SLOT}:" \
		-i "${ED%/}"/usr/bin/sia-ui || die

	insinto /usr/share/sia-ui
	doins -r {assets,css,dist,js,plugins,app.html,app.js,package.json}

	# Install icons and desktop entry
	local size
	for size in 16 22 24 32 48 64 128 256; do
		newicon -s ${size} "${FILESDIR}/icon/${size}.png" sia-ui.png
	done
	make_desktop_entry sia-ui Sia-UI sia-ui Utility \
		"Terminal=false\\nStartupNotify=true\\nStartupWMClass=Sia-UI"
	sed "/^Exec/s/$/ %f/" -i "${ED%/}"/usr/share/applications/*.desktop || die
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
