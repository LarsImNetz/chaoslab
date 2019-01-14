# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils gnome2-utils vala

DESCRIPTION="Simple animated Gif screen recorder"
HOMEPAGE="https://github.com/phw/peek"
SRC_URI="https://github.com/phw/peek/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gnome-shell keybinder open-filemanager test"

RDEPEND="
	dev-libs/glib:2
	media-gfx/gifski
	media-video/ffmpeg[X,encode,vpx,xcb]
	x11-libs/gtk+:3
	gnome-shell? (
		media-libs/gst-plugins-good:1.0
		media-libs/gst-plugins-ugly:1.0
	)
	keybinder? ( dev-libs/keybinder:3 )
"
DEPEND="${RDEPEND}
	$(vala_depend)
	app-text/txt2man
	sys-devel/gettext
"

src_prepare() {
	cmake-utils_src_prepare
	vala_src_prepare
}

src_configure() {
	# shellcheck disable=SC2191,SC2207
	local mycmakeargs=(
		-DGSETTINGS_COMPILE=OFF
		-DDISABLE_GNOME_SHELL=$(usex !gnome-shell)
		-DDISABLE_OPEN_FILE_MANAGER=$(usex !open-filemanager)
		-DKEYBINDER_FOUND=$(usex keybinder 1 0)
		-DVALA_EXECUTABLE="${VALAC}"
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile

	# Compile helper programs for tests
	if use test; then
		cmake-utils_src_make -C tests
	fi
}

pkg_preinst() {
	gnome2_icon_savelist
	gnome2_schemas_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
	gnome2_schemas_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	gnome2_schemas_update
}
