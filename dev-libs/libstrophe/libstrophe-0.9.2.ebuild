# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A simple, lightweight C library for writing XMPP clients"
HOMEPAGE="http://strophe.im/libstrophe/"
SRC_URI="https://github.com/strophe/${PN}/releases/download/${PV}/${P}.tar.gz"
RESTRICT="mirror"

LICENSE="|| ( MIT GPL-3 )"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="doc examples libressl +ssl +xml"

DOCS=( README ChangeLog )

RDEPEND="ssl? (
		!libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:0= )
	)
	xml? ( dev-libs/libxml2:2 )
	!xml? ( dev-libs/expat )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

PATCHES=( "${FILESDIR}/${P}-libressl.patch" )

src_configure() {
	# shellcheck disable=SC2207
	local myeconf=(
		$(use_enable ssl tls)
		$(use_with xml libxml2)
	)
	econf "${myeconf[@]}"
}
src_compile() {
	default
	if use doc; then
		doxygen || die
		HTML_DOCS=( docs/html/* )
	fi
}

src_install() {
	default
	use examples && dodoc -r examples
}
