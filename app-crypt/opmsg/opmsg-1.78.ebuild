# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit flag-o-matic

MY_PV="rel-${PV}s"
DESCRIPTION="opmsg message encryption (an alternative to GnuPG)"
HOMEPAGE="https://github.com/stealth/opmsg"
SRC_URI="https://github.com/stealth/${PN}/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="contrib libressl"

DEPEND="
	!libressl? ( dev-libs/openssl:0= )
	libressl? ( dev-libs/libressl:0= )"
RESTRICT="mirror"

DOCS=( README.md )

S="${WORKDIR}/${PN}-${MY_PV}"

src_prepare() {
	sed -i -e "/^CXXFLAGS/s:CXXFLAGS=:CXXFLAGS+=:" \
		-e "/^CXXFLAGS/s/-O2 //" \
		src/Makefile || die

	default
}

src_compile() {
	use libressl && append-cxxflags -DHAVE_LIBRESSL -DHAVE_BN_GENCB_NEW=0

	emake \
		CXX="$(tc-getCXX)" \
		LDFLAGS="${LDFLAGS}" \
		-C ./src

	if use contrib; then
		emake \
			CXX="$(tc-getCXX)" \
			LDFLAGS="${LDFLAGS}" \
			-C ./src contrib
	fi
}

src_install() {
	dobin src/opmsg
	einstalldocs

	if use contrib; then
		dobin src/{opmux,opcoin}
		dodoc README2.md
	fi
}
