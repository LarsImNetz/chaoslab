# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools

DESCRIPTION="An inotify-based file watching and job triggering command line utility"
HOMEPAGE="https://facebook.github.io/watchman"
SRC_URI="https://github.com/facebook/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror test"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="libressl +pcre"

RDEPEND="!libressl? ( dev-libs/openssl:0= )
	libressl? ( dev-libs/libressl:0= )
	pcre? ( dev-libs/libpcre )"
DEPEND="dev-cpp/glog"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	# shellcheck disable=SC2191,SC2207
	local myconf=(
		--disable-dependency-tracking
		--disable-cppclient
		--enable-lenient
		--without-ruby
		--without-python
		--with-buildinfo=Gentoo
		$(use_with pcre)
	)
	econf "${myconf[@]}"
}
