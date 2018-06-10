# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit gnome2 meson vala xdg-utils

DESCRIPTION="A native Linux SQL client built in Vala and GTK+"
HOMEPAGE="https://github.com/Alecaddd/sequeler"
SRC_URI="https://github.com/Alecaddd/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="app-crypt/libsecret
	dev-libs/glib
	dev-libs/granite
	dev-libs/libgee:0.8
	dev-libs/libxml2:2
	gnome-extra/libgda
	x11-libs/gtksourceview:3.0
	>=x11-libs/gtk+-3.20:3"
DEPEND="${RDEPEND}"

src_prepare() {
	gnome2_src_prepare
	vala_src_prepare
	default
}

pkg_preinst() {
	gnome2_icon_savelist
	gnome2_schemas_savelist
}

pkg_postinst() {
	xdg_desktop_database_update
	gnome2_icon_cache_update
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_desktop_database_update
	gnome2_icon_cache_update
	gnome2_schemas_update
}
