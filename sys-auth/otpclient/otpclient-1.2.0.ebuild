# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils gnome2-utils xdg-utils

DESCRIPTION="Simple GTK+ 3 OTP client (TOTP and HOTP)"
HOMEPAGE="https://github.com/paolostivanin/OTPClient"
SRC_URI="https://github.com/paolostivanin/OTPClient/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="dev-libs/libgcrypt:0=
	dev-libs/glib
	dev-libs/jansson
	dev-libs/libzip
	dev-libs/libcotp
	media-gfx/zbar
	>=media-libs/libpng-1.6.0
	>=x11-libs/gtk+-3.22:3"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

S="${WORKDIR}/OTPClient-${PV}"

src_prepare() {
	# Leave optimization level to user CFLAGS
	sed -i '14,21d' CMakeLists.txt || die

	cmake-utils_src_prepare
}

pkg_postinst() {
	xdg_desktop_database_update
	gnome2_icon_savelist
	gnome2_schemas_savelist
}

pkg_postrm() {
	gnome2_icon_cache_update
	gnome2_schemas_update
}
