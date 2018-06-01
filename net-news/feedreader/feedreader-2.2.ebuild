# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

VALA_MIN_API_VERSION="0.38"

inherit gnome2 meson vala

MY_PN="FeedReader"
DESCRIPTION="A modern desktop application designed to complement web-based RSS accounts"
HOMEPAGE="https://jangernert.github.io/FeedReader/"
SRC_URI="https://github.com/jangernert/${MY_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="$(vala_depend)
	app-crypt/libsecret[vala(+)]
	dev-db/sqlite:3
	dev-libs/gobject-introspection
	dev-libs/json-glib
	dev-libs/libgee:0.8
	dev-libs/libpeas
	dev-libs/libxml2
	media-gfx/gtkimageview
	media-libs/gd
	media-libs/gst-plugins-base:1.0
	net-libs/gnome-online-accounts[vala]
	net-libs/libsoup:2.4
	net-libs/rest
	net-libs/webkit-gtk:4
	net-misc/curl
	>=x11-libs/gtk+-3.22:3
	x11-libs/libnotify"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

S="${WORKDIR}/${MY_PN}-${PV}"

src_prepare() {
	gnome2_src_prepare
	vala_src_prepare
}

src_configure() {
	meson_src_configure
}

src_install() {
	meson_src_install
}

pkg_preinst() {
	gnome2_pkg_preinst
}

pkg_postinst() {
	gnome2_pkg_postinst
}

pkg_postrm() {
	gnome2_pkg_postrm
}
