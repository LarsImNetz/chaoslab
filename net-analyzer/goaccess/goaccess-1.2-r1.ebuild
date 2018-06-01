# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools

DESCRIPTION="A real-time web log analyzer and interactive viewer that runs in a terminal"
HOMEPAGE="https://goaccess.io"
SRC_URI="https://tar.goaccess.io/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="btree bzip2 debug geoip geoipv2 getline libressl ssl tokyocabinet +unicode zlib"

RDEPEND="sys-libs/ncurses:0=[unicode?]
	geoip? (
		!geoipv2? ( dev-libs/geoip )
		geoipv2? ( dev-libs/libmaxminddb:0= )
	)
	!tokyocabinet? ( dev-libs/glib:2 )
	tokyocabinet? (
		dev-db/tokyocabinet[bzip2?,zlib?]
		btree? (
			bzip2? ( app-arch/bzip2 )
			zlib? ( sys-libs/zlib )
		)
	)
	ssl? (
		!libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:0= )
	)"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

REQUIRED_USE="btree? ( tokyocabinet ) bzip2? ( btree ) geoipv2? ( geoip ) zlib? ( btree )"

src_prepare() {
	# Change path to GeoIP bases in config
	sed -i "s:/usr/local:/usr:" \
		config/goaccess.conf || die

	# Leave optimization level to user CFLAGS
	sed -i 's/-O2 //g' ./Makefile.am || die

	default
	eautomake
}

src_configure() {
	econf \
		$(use_enable bzip2 bzip) \
		$(use_enable zlib) \
		$(use_enable debug) \
		$(use_enable geoip geoip $(usex geoipv2 mmdb legacy)) \
		$(use_enable tokyocabinet tcb $(usex btree btree memhash)) \
		$(use_enable unicode utf8) \
		$(use_with getline) \
		$(use_with ssl openssl)
}

pkg_preinst() {
	# Install goaccess.conf as goaccess.conf.example
	mv "${ED%/}"/etc/goaccess.conf{,.example} || die
}

pkg_postinst() {
	if [ ! -e "${EROOT%/}"/etc/goaccess.conf ]; then
		elog "No goaccess.conf found, copying the example over"
		cp "${EROOT%/}"/etc/goaccess.conf{.example,} || die
	else
		elog "goaccess.conf found, please check example file for possible changes"
	fi
}
