# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools bash-completion-r1 gnome2-utils systemd user xdg-utils

MY_PV="${PV/\.0i/I}"
DESCRIPTION="A full node Bitcoin Cash implementation with GUI, daemon and utils"
HOMEPAGE="https://bitcoinxt.software"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="daemon dbus +gui libressl +qrcode reduce-exports test upnp utils +wallet zeromq"
LANGS="ach af:af_ZA ar be:be_BY bg bs ca ca@valencia ca:ca_ES cs cy da de el:el_GR en
	eo es es_CL es_DO es_MX es_UY et eu:eu_ES fa fa:fa_IR fi fr fr_CA gl gu:gu_IN he
	hi:hi_IN hr hu id:id_ID it ja ka kk:kk_KZ ko:ko_KR ky la lt lv:lv_LV mn ms:ms_MY
	nb nl pam pl pt_BR pt_PT ro:ro_RO ru ru:sah sk sl:sl_SI sq sr sv th:th_TH tr uk
	ur_PK uz@Cyrl vi vi:vi_VN zh:cmn zh_HK zh_CN zh_TW"

CDEPEND="dev-libs/boost:0=[threads(+)]
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
	zeromq? ( net-libs/zeromq )"
DEPEND="${CDEPEND}
	gui? ( dev-qt/linguist-tools )"
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
	# shellcheck disable=SC2086
	for l; do
		echo l10n_${LANG2USE["${l}"]}
	done
}

# shellcheck disable=SC2068
IUSE+=" $(bitcoin_lang2use ${!LANG2USE[@]})"

bitcoin_lang_requireduse() {
	local lang l10n
	# shellcheck disable=SC2068
	for l10n in ${!USE2LANGS[@]}; do
		for lang in ${USE2LANGS["${l10n}"]}; do
			continue 2
		done
		echo "l10n_${l10n}?"
	done
}

REQUIRED_USE+=" $(bitcoin_lang_requireduse)"

DOCS=( doc/{assets-attribution,bips,tor}.md )

S="${WORKDIR}/${PN}-${MY_PV}"

pkg_setup() {
	if use daemon; then
		enewgroup bitcoinxt
		enewuser bitcoinxt -1 -1 /var/lib/bitcoinxt bitcoinxt
	fi
}

src_prepare() {
	if use gui; then
		# Fix compatibility with LibreSSL
		eapply "${FILESDIR}/${PN}-0.11.0g-libressl.patch"

		local filt yeslang nolang lan ts x

		for lan in $LANGS; do
			lan="${lan/*:/}"
			# shellcheck disable=SC2086
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

		# shellcheck disable=SC1117
		filt="bitcoin_\\(${filt:2}\\)\\.\(qm\|ts\)"
		sed "/${filt}/d" -i 'src/qt/bitcoin_locale.qrc' || die
		# shellcheck disable=SC1117
		sed "s/locale\/${filt}/bitcoin.qrc/" -i 'src/Makefile.qt.include' || die
		einfo "Languages -- Enabled:$yeslang -- Disabled:$nolang"
	fi

	use daemon || sed -i 's/have bitcoind &&//;s/^\(complete -F _bitcoind \)bitcoind \(bitcoin-cli\)$/\1\2/' \
		contrib/bitcoind.bash-completion || die

	use utils || sed -i 's/have bitcoind &&//;s/^\(complete -F _bitcoind bitcoind\) bitcoin-cli$/\1/' \
		contrib/bitcoind.bash-completion || die

	default
	eautoreconf
}

src_configure() {
	# shellcheck disable=SC2207
	local myeconf=(
		--without-libs
		--disable-bench
		--disable-ccache
		--disable-maintainer-mode
		$(usex gui "--with-gui=qt5" --without-gui)
		$(use_with daemon)
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
			"Qt;Network;P2P;Office;Finance;" "MimeType=x-scheme-handler/bitcoincash;\nTerminal=false"

		doman contrib/debian/manpages/bitcoin-qt.1
	fi

	if use utils; then
		doman contrib/debian/manpages/bitcoin-cli.1
		use daemon || newbashcomp contrib/bitcoind.bash-completion bitcoin
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
	if [[ $(stat -c %a "${EROOT%/}/var/lib/bitcoinxt") != "750" ]]; then
		einfo "Fixing ${EROOT%/}/var/lib/bitcoinxt permissions"
		chown -R bitcoinxt:bitcoinxt "${EROOT%/}/var/lib/bitcoinxt" || die
		chmod 0750 "${EROOT%/}/var/lib/bitcoinxt" || die
	fi
	use gui && update_caches
}

pkg_postrm() {
	use gui && update_caches
}
