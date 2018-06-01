# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3 gnome2-utils xdg-utils meson

DESCRIPTION="A simple GTK+ frontend for mpv"
HOMEPAGE="https://gnome-mpv.github.io/"
EGIT_REPO_URI="https://github.com/gnome-mpv/gnome-mpv.git"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS=""

CDEPEND="dev-libs/glib
	media-libs/libepoxy
	>=media-video/mpv-0.27[libmpv]
	>=x11-libs/gtk+-3.20:3"
RDEPEND="${CDEPEND}
	x11-themes/gnome-icon-theme-symbolic"
DEPEND="${CDEPEND}
	dev-libs/appstream-glib
	virtual/pkgconfig"

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
