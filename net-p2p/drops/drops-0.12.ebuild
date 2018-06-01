# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit flag-o-matic

MY_PV="rel-${PV}s-newkey"
DESCRIPTION="A p2p transport network for opmsg end2end encrypted messages"
HOMEPAGE="https://github.com/stealth/drops"
SRC_URI="https://github.com/stealth/${PN}/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="libressl"

DEPEND="
	!libressl? ( dev-libs/openssl:0= )
	libressl? ( dev-libs/libressl:0= )"
RDEPEND="${DEPEND}
	app-crypt/opmsg"

RESTRICT="mirror"

S="${WORKDIR}/${PN}-${MY_PV}"

src_prepare() {
	sed -i -e "/^CXXFLAGS/s:CXXFLAGS=:CXXFLAGS+=:" \
		-e "/^CXXFLAGS/s/-O2 //" \
		src/Makefile || die

	default
}

src_compile() {
	use libressl && append-cxxflags -DHAVE_LIBRESSL

	CXX="$(tc-getCXX)" LDFLAGS="${LDFLAGS}" \
		emake -C src
}

src_install() {
	dobin src/dropsd
	dodoc README.md
}

pkg_postinst() {
	ewarn
	ewarn "Note: drops is in the beta testing phase."
	ewarn
	ewarn "There are easier things than to get a p2p network flying and tested."
	ewarn "For this reason, expect some changes to the commandline/config options."
	ewarn
}
