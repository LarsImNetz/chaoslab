# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit systemd user

MY_P=${P/_p/.r}
DESCRIPTION="An IP-Transparent Tor Hidden Service Connector"
HOMEPAGE="https://www.onioncat.org"
SRC_URI="https://www.cypherpunk.at/ocat/download/Source/current/${MY_P}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug +http i2p log +queue relay +rtt"

RDEPEND="net-vpn/tor
	i2p? (
		|| ( net-vpn/i2pd net-vpn/i2p )
	)"

RESTRICT="mirror"

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
	local myeconf=(
		$(use_enable debug)
		$(use_enable log packet-log)
		$(use_enable http handle-http)
		$(use_enable queue packet-queue)
		$(use_enable !relay check-ipsrc)
		$(use_enable rtt)
	)
	econf ${myeconf[@]}
}

src_install() {
	default

	use i2p || rm "${ED%/}/usr/bin/gcat" || die

	if use i2p; then
		newinitd "${FILESDIR}"/garlicat.initd garlicat
		newconfd "${FILESDIR}"/garlicat.confd garlicat
		systemd_dounit "${FILESDIR}"/garlicat.service
	fi

	newinitd "${FILESDIR}"/onioncat.initd ${PN}
	newconfd "${FILESDIR}"/onioncat.confd ${PN}
	systemd_dounit "${FILESDIR}"/onioncat.service

	insinto /var/lib/tor
	doins glob_id.txt hosts.onioncat

	diropts -o onioncat -g onioncat -m 0750
	dodir /var/log/onioncat
}

pkg_postinst() {
	einfo
	elog "See https://www.onioncat.org/configuration/"
	elog "for configuration guide."
	einfo
}
