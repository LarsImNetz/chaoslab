# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

DESCRIPTION="C library that generates TOTP and HOTP"
HOMEPAGE="https://github.com/paolostivanin/libcotp"
SRC_URI="https://github.com/paolostivanin/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=">=dev-libs/libbaseencode-1.0.5
	dev-libs/libgcrypt:0="
RDEPEND="${DEPEND}"

src_prepare() {
	# Leave optimization level to user CFLAGS
	sed -i '/CMAKE_C_FLAGS/d' CMakeLists.txt || die

	cmake-utils_src_prepare
}
