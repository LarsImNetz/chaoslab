# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils systemd user

DESCRIPTION="Advanced and secure webserver"
HOMEPAGE="https://www.hiawatha-webserver.org"
SRC_URI="https://www.hiawatha-webserver.org/files/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+cache ipv6 monitor +rewrite +rproxy +ssl tomahawk +xslt"

RDEPEND="sys-libs/zlib
	ssl? ( >=net-libs/mbedtls-2.8.0[threads] )
	xslt? (
		dev-libs/libxslt
		dev-libs/libxml2
	)"
DEPEND="${RDEPEND}"
PDEPEND="monitor? ( www-apps/hiawatha-monitor )"

RESTRICT="mirror"
PATCHES=( "${FILESDIR}/${PN}-9.5-cflags.patch" )

pkg_setup() {
	enewgroup hiawatha
	enewuser hiawatha -1 -1 /var/www/hiawatha hiawatha
}

src_prepare() {
	sed -i "s:#ServerId =.*:ServerId = hiawatha:" \
		config/hiawatha.conf.in || die

	sed -i "s:www-data:hiawatha:g" \
		extra/logrotate.in || die

	cmake-utils_src_prepare
}

src_configure() {
	# shellcheck disable=SC2207,SC2191
	local mycmakeargs=(
		-DCONFIG_DIR:STRING="/etc/hiawatha"
		-DENABLE_CACHE=$(usex cache)
		-DENABLE_IPV6=$(usex ipv6)
		-DENABLE_LOADCHECK=$(usex kernel_linux)
		-DENABLE_MONITOR=$(usex monitor)
		-DENABLE_RPROXY=$(usex rproxy)
		-DENABLE_TLS=$(usex ssl)
		-DENABLE_TOMAHAWK=$(usex tomahawk)
		-DENABLE_TOOLKIT=$(usex rewrite)
		-DENABLE_XSLT=$(usex xslt)
		-DLOG_DIR:STRING="/var/log/hiawatha"
		-DPID_DIR:STRING="/run"
		-DUSE_SYSTEM_MBEDTLS=$(usex ssl)
		-DWEBROOT_DIR:STRING="/var/www/hiawatha"
		-DWORK_DIR:STRING="/var/lib/hiawatha"
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	rm -r "${ED%/}"/var/www/hiawatha/* || die

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"

	diropts -o hiawatha -g hiawatha -m 0750
	dodir /var/{lib,log}/hiawatha
}
