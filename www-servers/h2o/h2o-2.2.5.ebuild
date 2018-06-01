# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

USE_RUBY="ruby23 ruby24 ruby25"

inherit cmake-utils ruby-single systemd user

DESCRIPTION="An optimized HTTP server with support for HTTP/1.x and HTTP/2"
HOMEPAGE="https://h2o.examp1e.net"
SRC_URI="https://github.com/h2o/h2o/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="libh2o libressl libuv +mruby websocket"
REQUIRED_USE="libuv? ( libh2o )
	websocket? ( libh2o )"

RDEPEND="
	libh2o? (
		libuv? ( >=dev-libs/libuv-1.0.0 )
		websocket? ( net-libs/wslay )
	)
	!libressl? ( dev-libs/openssl:0= )
	libressl? ( dev-libs/libressl:0= )"
DEPEND="${RDEPEND}
	mruby? (
		sys-devel/bison
		${RUBY_DEPS}
	)"
RDEPEND+=" app-misc/ca-certificates"

PATCHES=(
	"${FILESDIR}/${PN}-2.2.3-system_ca.patch"
	"${FILESDIR}/${P}-libressl.patch"
)

pkg_setup() {
	enewgroup h2o
	enewuser h2o -1 -1 -1 h2o
}

src_prepare() {
	# shellcheck disable=SC2016
	# Leave optimization level to user CFLAGS
	sed -i 's/-O2 -g ${CC_WARNING_FLAGS} //g' ./CMakeLists.txt \
		|| die "sed fix failed!"

	cmake-utils_src_prepare
}

src_configure() {
	# shellcheck disable=SC2191
	local mycmakeargs=(
		-DCMAKE_INSTALL_SYSCONFDIR="${EPREFIX}"/etc/h2o
		-DDISABLE_LIBUV="$(usex !libuv)"
		-DWITHOUT_LIBS="$(usex !libh2o)"
		-DWITH_BUNDLED_SSL=OFF
		-DWITH_MRUBY="$(usex mruby)"
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	newinitd "${FILESDIR}"/h2o.initd h2o
	systemd_dounit "${FILESDIR}"/h2o.service

	insinto /etc/h2o
	doins "${FILESDIR}"/h2o.conf

	insinto /etc/logrotate.d
	newins "${FILESDIR}"/h2o.logrotate-r3 h2o

	diropts -o h2o -g h2o -m 0700
	keepdir /var/log/h2o
}
