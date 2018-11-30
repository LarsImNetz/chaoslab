# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools bash-completion-r1 desktop systemd user xdg-utils

MY_PV="${PV/\.0k/K}"
DESCRIPTION="A full node Bitcoin Cash implementation with GUI, daemon and utils"
HOMEPAGE="https://bitcoinxt.software"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="daemon dbus +gui libressl +qrcode reduce-exports test upnp utils +wallet zeromq"
REQUIRED_USE="dbus? ( gui ) qrcode? ( gui )"

CDEPEND="
	dev-libs/boost:0=[threads(+)]
	dev-libs/libevent
	net-misc/curl
	gui? (
		dev-libs/protobuf
		dev-qt/qtgui:5
		dev-qt/qtnetwork:5
		dev-qt/qtwidgets:5
		dbus? ( dev-qt/qtdbus:5 )
		qrcode? ( media-gfx/qrencode )
	)
	!libressl? ( dev-libs/openssl:0=[-bindist] )
	libressl? ( dev-libs/libressl:0= )
	upnp? ( net-libs/miniupnpc )
	wallet? ( sys-libs/db:4.8[cxx] )
	zeromq? ( net-libs/zeromq )
"
DEPEND="${CDEPEND}
	gui? ( dev-qt/linguist-tools:5 )"
RDEPEND="${CDEPEND}
	daemon? (
		!net-p2p/bitcoind
		!net-p2p/bitcoin-abc[daemon]
		!net-p2p/bitcoin-unlimited[daemon]
	)
	gui?  (
		!net-p2p/bitcoin-qt
		!net-p2p/bitcoin-abc[gui]
		!net-p2p/bitcoin-unlimited[gui]
	)
	utils? (
		!net-p2p/bitcoin-cli
		!net-p2p/bitcoin-tx
		!net-p2p/bitcoin-abc[utils]
		!net-p2p/bitcoin-unlimited[utils]
	)
"

DOCS=( doc/{assets-attribution,bips,tor}.md )

S="${WORKDIR}/${PN}-${MY_PV}"

pkg_setup() {
	if use daemon; then
		enewgroup bitcoinxt
		enewuser bitcoinxt -1 -1 /var/lib/bitcoinxt bitcoinxt
	fi
}

src_prepare() {
	# Fix compatibility with LibreSSL
	use gui && eapply "${FILESDIR}/${PN}-0.11.0g-libressl.patch"

	use daemon || sed -i 's/have bitcoind &&//;s/^\(complete -F _bitcoind \)bitcoind \(bitcoin-cli\)$/\1\2/' \
		contrib/bitcoind.bash-completion || die

	use utils || sed -i 's/have bitcoind &&//;s/^\(complete -F _bitcoind bitcoind\) bitcoin-cli$/\1/' \
		contrib/bitcoind.bash-completion || die

	echo '#!/bin/true' >share/genbuild.sh || die
	mkdir -p src/obj || die
	echo "#define BUILD_SUFFIX gentoo${PVR#${PV}}" >src/obj/build.h || die

	default
	eautoreconf
}

src_configure() {
	# shellcheck disable=SC2207
	local myeconf=(
		--disable-bench
		--disable-ccache
		--disable-gui-tests
		--disable-maintainer-mode
		--without-libs
		$(use_with daemon)
		$(use_with gui)
		$(use_with qrcode qrencode)
		$(use_with upnp miniupnpc)
		$(use_with utils)
		$(use_enable reduce-exports)
		$(use_enable test tests)
		$(use_enable wallet)
		$(use_enable zeromq zmq)
	)
	econf "${myeconf[@]}"
}

src_install() {
	default

	if use daemon; then
		newinitd "${FILESDIR}/${PN}.initd" "${PN}"
		newconfd "${FILESDIR}/${PN}.confd" "${PN}"
		systemd_newunit "${FILESDIR}/${PN}.service-r1" "${PN}.service"

		insinto /etc/bitcoinxt
		newins "${FILESDIR}/${PN}.conf" bitcoin.conf
		fowners bitcoinxt:bitcoinxt /etc/bitcoinxt/bitcoin.conf
		fperms 600 /etc/bitcoinxt/bitcoin.conf
		newins contrib/debian/examples/bitcoin.conf bitcoin.conf.example

		doman contrib/debian/manpages/{bitcoind.1,bitcoin.conf.5}
		newbashcomp contrib/bitcoind.bash-completion bitcoin

		insinto /etc/logrotate.d
		newins "${FILESDIR}/${PN}.logrotate-r1" "${PN}"

		diropts -o bitcoinxt -g bitcoinxt -m 0750
		keepdir /var/lib/bitcoinxt/.bitcoin
	fi

	if use gui; then
		local X
		for X in 16 32 64 128 256; do
			newicon -s ${X} "share/pixmaps/bitcoin${X}.png" bitcoin.png
		done
		# shellcheck disable=SC1117
		make_desktop_entry "bitcoin-qt %u" "Bitcoin XT" "bitcoin" \
			"Qt;Network;P2P;Office;Finance;" \
			"MimeType=x-scheme-handler/bitcoincash;\nTerminal=false"

		doman contrib/debian/manpages/bitcoin-qt.1
	fi

	if use utils; then
		doman contrib/debian/manpages/bitcoin-cli.1
		use daemon || newbashcomp contrib/bitcoind.bash-completion bitcoin
	fi
}

update_caches() {
	if type gtk-update-icon-cache &>/dev/null; then
		ebegin "Updating GTK icon cache"
		gtk-update-icon-cache "${EROOT}/usr/share/icons/hicolor"
		eend $?
	fi
	xdg_desktop_database_update
}

pkg_postinst() {
	use gui && update_caches
}

pkg_postrm() {
	use gui && update_caches
}
