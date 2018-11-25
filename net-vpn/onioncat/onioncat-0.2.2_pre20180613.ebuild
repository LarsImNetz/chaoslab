# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit systemd user

# v0.2.2.r578 See $PACKAGE_VERSION in configure file
MY_PV="8e7f6eb655e342d14c2f06411d9c0c459b8f6f8f"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="An IP-Transparent Tor Hidden Service Connector"
HOMEPAGE="https://www.onioncat.org"
SRC_URI="https://github.com/rahra/onioncat/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug +http i2p log +queue relay +rtt"

RDEPEND="
	net-vpn/tor
	i2p? ( || ( net-vpn/i2pd net-vpn/i2p ) )
"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	enewgroup onioncat
	enewuser onioncat -1 -1 -1 onioncat
}

src_prepare() {
	sed -i \
		-e '/CFLAGS=/s#-O2##g' \
		-e '/CFLAGS=/s#-g##g' \
		configure || die

	default
}

src_configure() {
	# shellcheck disable=SC2207
	local myeconf=(
		$(use_enable debug)
		$(use_enable log packet-log)
		$(use_enable http handle-http)
		$(use_enable queue packet-queue)
		$(use_enable !relay check-ipsrc)
		$(use_enable rtt)
	)
	econf "${myeconf[@]}"
}

src_install() {
	default

	if use i2p; then
		rm "${ED}/usr/bin/gcat" || die
		newinitd "${FILESDIR}"/garlicat.initd garlicat
		newconfd "${FILESDIR}"/garlicat.confd garlicat
		systemd_dounit "${FILESDIR}"/garlicat.service
	fi

	newinitd "${FILESDIR}"/onioncat.initd "${PN}"
	newconfd "${FILESDIR}"/onioncat.confd "${PN}"
	systemd_dounit "${FILESDIR}"/onioncat.service

	insinto /var/lib/tor
	doins glob_id.txt hosts.onioncat

	diropts -o onioncat -g onioncat -m 0750
	keepdir /var/log/onioncat
}

pkg_postinst() {
	einfo
	elog "See https://www.onioncat.org/configuration/"
	elog "for configuration guide."
	einfo
}
