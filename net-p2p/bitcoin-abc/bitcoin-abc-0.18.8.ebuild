# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools bash-completion-r1 desktop systemd user xdg-utils

DESCRIPTION="A full node Bitcoin Cash implementation with GUI, daemon and utils"
HOMEPAGE="https://bitcoinabc.org"
SRC_URI="https://github.com/Bitcoin-ABC/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="daemon dbus +gui hardened libressl +qrcode +reduce-exports system-univalue test upnp utils +wallet zeromq"
REQUIRED_USE="dbus? ( gui ) qrcode? ( gui )"

CDEPEND="
	dev-libs/boost:0=[threads(+)]
	dev-libs/libevent
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
	system-univalue? ( >=dev-libs/univalue-1.0.4 )
	upnp? ( net-libs/miniupnpc )
	wallet? (
		|| (
			sys-libs/db:5.3[cxx]
			sys-libs/db:6.0[cxx]
			sys-libs/db:6.1[cxx]
			sys-libs/db:6.2[cxx]
		)
	)
	zeromq? ( net-libs/zeromq )
"
DEPEND="${CDEPEND}
	gui? ( dev-qt/linguist-tools:5 )
"
RDEPEND="${CDEPEND}
	daemon? (
		!net-p2p/bitcoind
		!net-p2p/bitcoinxt[daemon]
		!net-p2p/bitcoin-unlimited[daemon]
	)
	gui?  (
		!net-p2p/bitcoin-qt
		!net-p2p/bitcoinxt[gui]
		!net-p2p/bitcoin-unlimited[gui]
	)
	utils? (
		!net-p2p/bitcoin-cli
		!net-p2p/bitcoin-tx
		!net-p2p/bitcoinxt[utils]
		!net-p2p/bitcoin-unlimited[utils]
	)
"

pkg_setup() {
	if use daemon; then
		enewgroup bitcoin
		enewuser bitcoin -1 -1 /var/lib/bitcoin bitcoin
	fi
}

src_prepare() {
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
		$(use_with system-univalue)
		$(use_with upnp miniupnpc)
		$(use_with utils)
		$(use_enable hardened hardening)
		$(use_enable reduce-exports)
		$(use_enable test tests)
		$(use_enable wallet)
		$(use_enable zeromq zmq)
	)
	econf "${myeconf[@]}"
}

src_test() {
	emake -C src bitcoin_test_check
}

src_install() {
	default

	if use daemon; then
		newinitd "${FILESDIR}/${PN}.initd" "${PN}"
		newconfd "${FILESDIR}/${PN}.confd" "${PN}"
		systemd_newunit "${FILESDIR}/${PN}.service-r1" "${PN}.service"

		insinto /etc/bitcoin
		newins "${FILESDIR}/${PN}.conf" bitcoin.conf
		fowners bitcoin:bitcoin /etc/bitcoin/bitcoin.conf
		fperms 600 /etc/bitcoin/bitcoin.conf
		newins contrib/debian/examples/bitcoin.conf bitcoin.conf.example
		doins share/rpcuser/rpcuser.py

		doman doc/man/bitcoind.1
		newbashcomp contrib/bitcoind.bash-completion bitcoind

		insinto /etc/logrotate.d
		newins "${FILESDIR}/${PN}.logrotate" "${PN}"

		diropts -o bitcoin -g bitcoin -m 0750
		keepdir /var/lib/bitcoin/.bitcoin
	fi

	if use gui; then
		local X
		for X in 16 32 64 128 256; do
			newicon -s ${X} "share/pixmaps/bitcoin-abc${X}.png" bitcoin.png
		done
		# shellcheck disable=SC1117
		make_desktop_entry "bitcoin-qt %u" "Bitcoin ABC" "bitcoin" \
			"Qt;Network;P2P;Office;Finance;" \
			"MimeType=x-scheme-handler/bitcoincash;\nTerminal=false"

		doman doc/man/bitcoin-qt.1
	fi

	if use utils; then
		doman doc/man/bitcoin-{cli,tx}.1
		newbashcomp contrib/bitcoin-cli.bash-completion bitcoin-cli
		newbashcomp contrib/bitcoin-tx.bash-completion bitcoin-tx
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
