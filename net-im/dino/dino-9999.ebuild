# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CMAKE_MAKEFILE_GENERATOR="ninja"
VALA_MIN_API_VERSION="0.34"

inherit cmake-utils git-r3 gnome2-utils vala

DESCRIPTION="A modern Jabber/XMPP Client using GTK+/Vala"
HOMEPAGE="https://dino.im"
EGIT_REPO_URI="https://github.com/dino/dino.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""

RDEPEND="
	app-crypt/gpgme:1
	dev-db/sqlite:3
	dev-libs/libgcrypt:0=
	dev-libs/libgee:0.8
	net-libs/libsoup
	media-gfx/qrencode
	x11-libs/gtk+:3
"
DEPEND="${RDEPEND}
	$(vala_depend)
	sys-devel/gettext
"

src_prepare() {
	cmake-utils_src_prepare
}

src_configure() {
	# shellcheck disable=SC2086
	if has test ${FEATURES}; then
		mycmakeargs+=("-DBUILD_TESTS=yes")
	fi

	cmake-utils_src_configure
}

src_test() {
	"${BUILD_DIR}"/xmpp-vala-test || die
}

pkg_preinst() {
	gnome2_icon_savelist
}

update_caches() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}

pkg_postinst() {
	update_caches
}

pkg_postrm() {
	update_caches
}
