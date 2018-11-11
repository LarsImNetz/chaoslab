# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CMAKE_MAKEFILE_GENERATOR="emake"

inherit cmake-utils

MY_PV="${PV/0_p}"
DESCRIPTION="BLS signatures in C++, using the relic toolkit"
HOMEPAGE="https://github.com/codablock/bls-signatures"
SRC_URI="https://github.com/codablock/${PN}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"

DEPEND="
	dev-libs/gmp:0
	dev-libs/libsodium[static-libs]
"
RDEPEND="${DEPEND}"

PATCHES=( "${FILESDIR}/${PN}-0-cmake.patch" )

S="${WORKDIR}/${PN}-${MY_PV}"

src_prepare() {
	sed -i "s:lib):$(get_libdir)):g" src/CMakeLists.txt || die
	sed -i -e "s:lib :$(get_libdir) :" -e "s:lib):$(get_libdir)):g" \
		contrib/relic/src/CMakeLists.txt || die

	cmake-utils_src_prepare
}

src_configure() {
	# shellcheck disable=SC2191
	local mycmakeargs=(
		-DSHLIB=ON
		-DSTLIB=ON
		-DDEBUG=OFF
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	rm -r "${ED%/}"/usr/cmake || die
}
