# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools bash-completion-r1 gnome2-utils systemd user xdg-utils

DESCRIPTION="A full node Bitcoin Cash implementation with GUI, daemon and utils"
HOMEPAGE="https://bitcoinabc.org"
SRC_URI="https://github.com/Bitcoin-ABC/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="daemon dbus +gui hardened libressl +qrcode reduce-exports system-univalue test upnp utils +wallet zeromq"
LANGS="af af:af_ZA ar be:be_BY bg bg:bg_BG ca ca@valencia ca:ca_ES cs cy da de el el:el_GR en en_GB
	eo es es_AR es_CL es_CO es_DO es_ES es_MX es_UY es_VE et et:et_EE eu:eu_ES fa fa:fa_IR fi
	fr fr_CA fr:fr_FR gl he hi:hi_IN hr hu id:id_ID it it:it_IT ja ka kk:kk_KZ ko:ko_KR ku:ku_IQ ky la lt
	lv:lv_LV mk:mk_MK mn ms:ms_MY nb ne nl pam pl pt_BR pt_PT ro ro:ro_RO ru ru:ru_RU sk sl:sl_SI sq sr
	sr-Latn:sr@latin sv ta th:th_TH tr tr:tr_TR uk ur_PK uz@Cyrl vi vi:vi_VN zh zh_CN zh_HK zh_TW"

CDEPEND="dev-libs/boost:0=[threads(+)]
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
	system-univalue? ( dev-libs/univalue )
	upnp? ( net-libs/miniupnpc )
	wallet? ( sys-libs/db:4.8[cxx] )
	zeromq? ( net-libs/zeromq )"
DEPEND="${CDEPEND}
	gui? ( dev-qt/linguist-tools )"
RDEPEND="${CDEPEND}
	daemon? (
		!net-p2p/bitcoind
		!net-p2p/bitcoinxt[daemon]
		!net-p2p/bitcoin-unlimited[daemon]
		!net-p2p/bucash[daemon]
	)
	gui?  (
		!net-p2p/bitcoin-qt
		!net-p2p/bitcoinxt[gui]
		!net-p2p/bitcoin-unlimited[gui]
		!net-p2p/bucash[gui]
	)
	utils? (
		!net-p2p/bitcoin-cli
		!net-p2p/bitcoin-tx
		!net-p2p/bitcoinxt[utils]
		!net-p2p/bitcoin-unlimited[utils]
		!net-p2p/bucash[utils]
	)"

REQUIRED_USE="dbus? ( gui ) qrcode? ( gui )"

declare -A LANG2USE USE2LANGS
bitcoin_langs_prep() {
	local lang l10n
	for lang in ${LANGS}; do
		l10n="${lang/:*/}"
		l10n="${l10n/[@_]/-}"
		lang="${lang/*:/}"
		LANG2USE["${lang}"]="${l10n}"
		USE2LANGS["${l10n}"]+=" ${lang}"
	done
}
bitcoin_langs_prep

bitcoin_lang2use() {
	local l
	for l; do
		echo l10n_${LANG2USE["${l}"]}
	done
}

IUSE+=" $(bitcoin_lang2use ${!LANG2USE[@]})"

bitcoin_lang_requireduse() {
	local lang l10n
	for l10n in ${!USE2LANGS[@]}; do
		for lang in ${USE2LANGS["${l10n}"]}; do
			continue 2
		done
		echo "l10n_${l10n}?"
	done
}

REQUIRED_USE+=" $(bitcoin_lang_requireduse)"

pkg_setup() {
	if use daemon; then
		enewgroup bitcoin
		enewuser bitcoin -1 -1 /var/lib/bitcoin bitcoin
	fi
}

src_prepare() {
	if use gui; then
		local filt= yeslang= nolang= lan ts x

		for lan in $LANGS; do
			lan="${lan/*:/}"
			if [ ! -e src/qt/locale/bitcoin_$lan.ts ]; then
				continue
				die "Language '$lan' no longer supported. Ebuild needs update."
			fi
		done

		for ts in src/qt/locale/*.ts; do
			x="${ts/*bitcoin_/}"
			x="${x/.ts/}"
			if ! use "$(bitcoin_lang2use "$x")"; then
				nolang="$nolang $x"
				rm "$ts" || die
				filt="$filt\\|$x"
			else
				yeslang="$yeslang $x"
			fi
		done

		filt="bitcoin_\\(${filt:2}\\)\\.\(qm\|ts\)"
		sed "/${filt}/d" -i 'src/qt/bitcoin_locale.qrc' || die
		sed "s/locale\/${filt}/bitcoin.qrc/" -i 'src/Makefile.qt.include' || die
		einfo "Languages -- Enabled:$yeslang -- Disabled:$nolang"
	fi

	default
	eautoreconf
}

src_configure() {
	local myeconf=(
		--without-libs
		--disable-bench
		--disable-ccache
		--disable-maintainer-mode
		$(usex gui "--with-gui=qt5" --without-gui)
		$(use_with daemon)
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
	econf ${myeconf[@]}
}

src_test() {
	emake -C src bitcoin_test_check
}

src_install() {
	default

	if use daemon; then
		newinitd "${FILESDIR}"/${PN}.initd-r3 ${PN}
		newconfd "${FILESDIR}"/${PN}.confd-r3 ${PN}
		systemd_newunit "${FILESDIR}"/${PN}.service-r1 ${PN}.service
		systemd_newtmpfilesd "${FILESDIR}"/${PN}.tmpfilesd-r1 ${PN}.conf

		insinto /etc/bitcoin
		newins "${FILESDIR}"/${PN}.conf bitcoin.conf
		fowners bitcoin:bitcoin /etc/bitcoin/bitcoin.conf
		fperms 600 /etc/bitcoin/bitcoin.conf
		newins contrib/debian/examples/bitcoin.conf bitcoin.conf.example
		doins share/rpcuser/rpcuser.py

		doman doc/man/bitcoind.1
		newbashcomp contrib/bitcoind.bash-completion bitcoind

		insinto /etc/logrotate.d
		newins "${FILESDIR}"/${PN}.logrotate ${PN}

		diropts -o bitcoin -g bitcoin -m 0750
		dodir /var/lib/bitcoin/.bitcoin
	fi

	if use gui; then
		local X
		for X in 16 32 64 128 256; do
			newicon -s ${X} "share/pixmaps/bitcoin${X}.png" bitcoin.png
		done
		make_desktop_entry "bitcoin-qt %u" "Bitcoin ABC" "bitcoin" \
			"Qt;Network;P2P;Office;Finance;" "MimeType=x-scheme-handler/bitcoincash;\nTerminal=false"

		doman doc/man/bitcoin-qt.1
	fi

	if use utils; then
		doman doc/man/bitcoin-{cli,tx}.1
		newbashcomp contrib/bitcoin-cli.bash-completion bitcoin-cli
		newbashcomp contrib/bitcoin-tx.bash-completion bitcoin-tx
	fi
}

pkg_preinst() {
	use gui && gnome2_icon_savelist
}

update_caches() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}

pkg_postinst() {
	use gui && update_caches
}

pkg_postrm() {
	use gui && update_caches
}
