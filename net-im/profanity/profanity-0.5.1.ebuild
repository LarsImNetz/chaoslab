# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit autotools eutils python-single-r1

DESCRIPTION="A console based XMPP client inspired by Irssi"
HOMEPAGE="http://profanity.im"
SRC_URI="https://github.com/boothj5/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="c-plugins icons +largefile libnotify +otr pgp plugins python-plugins test +themes xscreensaver"

CDEPEND="dev-libs/glib:2
	net-misc/curl
	sys-apps/util-linux:0
	sys-libs/ncurses:0[unicode]
	sys-libs/readline:0
	|| (
		>=dev-libs/libmesode-0.9.1[ssl]
		>=dev-libs/libstrophe-0.9.1[ssl,xml]
	)
	icons? ( >=x11-libs/gtk+-2.24.10:2 )
	libnotify? ( x11-libs/libnotify )
	otr? ( net-libs/libotr )
	pgp? ( app-crypt/gpgme )
	python-plugins? ( ${PYTHON_DEPS} )
	xscreensaver? ( x11-libs/libXScrnSaver )"
DEPEND="${CDEPEND}
	virtual/pkgconfig
	test? ( dev-util/cmocka )"
RDEPEND="${CDEPEND}
	libnotify? ( virtual/notification-daemon )"
REQUIRED_USE="c-plugins? ( plugins )
	python-plugins? ( plugins ${PYTHON_REQUIRED_USE} )"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable c-plugins) \
		$(use_enable icons) \
		$(use_enable largefile) \
		$(use_enable libnotify notifications) \
		$(use_enable otr) \
		$(use_enable pgp) \
		$(use_enable plugins) \
		$(use_enable python-plugins) \
		$(use_with themes) \
		$(use_with xscreensaver) \
		|| die "econf failed"
}

src_install() {
	default
	prune_libtool_files
}
