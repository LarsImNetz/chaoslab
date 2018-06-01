# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit gnome2-utils xdg

ELECTRON_SLOT="1.7"
DESCRIPTION="The graphical front-end for Sia"
HOMEPAGE="https://sia.tech"
SRC_URI="https://github.com/NebulousLabs/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=">=net-libs/nodejs-6.0.0"
RDEPEND="net-p2p/Sia
	dev-util/electron-bin:${ELECTRON_SLOT}"

pkg_setup() {
	has network-sandbox $FEATURES && \
		die "net-p2p/Sia-UI requires 'network-sandbox' to be disabled in FEATURES"
}

src_prepare() {
	npm install || die
	default
}

src_compile() {
	npm run build || die
}

src_install() {
	newbin "${FILESDIR}"/Sia-UI-launcher.sh sia-ui
	sed "s:%%ELECTRON%%:electron-${ELECTRON_SLOT}:" \
		-i "${ED%/}"/usr/bin/sia-ui || die

	insinto /usr/lib/sia-ui
	doins -r {plugins,assets,css,dist,index.html,package.json,js}

	# Install icons and desktop entry
	newicon assets/icon.ico sia.ico
	make_desktop_entry sia-ui Sia /usr/share/pixmaps/sia.ico \
		Utility "Terminal=false"
	sed "/^Exec/s/$/ %f/" -i \
		"${ED%/}"/usr/share/applications/*.desktop || die
}

pkg_preinst() {
	xdg_pkg_preinst
	gnome2_icon_savelist
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_icon_cache_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_icon_cache_update
}
