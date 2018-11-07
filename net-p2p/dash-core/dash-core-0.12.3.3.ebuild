# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools bash-completion-r1 gnome2-utils systemd user xdg-utils

MY_PV="${PV/_/-}"
MY_P="dash-${MY_PV}"

DESCRIPTION="A peer-to-peer privacy-centric digital currency"
HOMEPAGE="https://www.dash.org"
SRC_URI="https://github.com/dashpay/dash/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="daemon dbus +gui hardened libressl +qrcode reduce-exports system-univalue test upnp utils +wallet zeromq"
REQUIRED_USE="dbus? ( gui ) qrcode? ( gui )"
LANGS="bg de en es fi fr it ja nl pl pt pt_BR ru sk sv vi zh_CN zh_TW"

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
RDEPEND="${CDEPEND}"

declare -A LANG2USE USE2LANGS
dash_langs_prep() {
	local lang l10n
	for lang in ${LANGS}; do
		l10n="${lang/:*/}"
		l10n="${l10n/[@_]/-}"
		lang="${lang/*:/}"
		LANG2USE["${lang}"]="${l10n}"
		USE2LANGS["${l10n}"]+=" ${lang}"
	done
}
dash_langs_prep

dash_lang2use() {
	local l
	# shellcheck disable=SC2086
	for l; do
		echo l10n_${LANG2USE["${l}"]}
	done
}

# shellcheck disable=SC2068
IUSE+=" $(dash_lang2use ${!LANG2USE[@]})"

dash_lang_requireduse() {
	local lang l10n
	# shellcheck disable=SC2068
	for l10n in ${!USE2LANGS[@]}; do
		for lang in ${USE2LANGS["${l10n}"]}; do
			continue 2
		done
		echo "l10n_${l10n}?"
	done
}

REQUIRED_USE+=" $(dash_lang_requireduse)"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	if use daemon; then
		enewgroup dash
		enewuser dash -1 -1 /var/lib/dash dash
	fi
}

src_prepare() {
	if use gui; then
		local filt yeslang nolang lan ts x

		for lan in $LANGS; do
			lan="${lan/*:/}"
			# shellcheck disable=SC2086
			if [ ! -e src/qt/locale/dash_$lan.ts ]; then
				continue
				die "Language '$lan' no longer supported. Ebuild needs update."
			fi
		done

		for ts in src/qt/locale/*.ts; do
			x="${ts/*dash_/}"
			x="${x/.ts/}"
			if ! use "$(dash_lang2use "$x")"; then
				nolang="$nolang $x"
				rm "$ts" || die
				filt="$filt\\|$x"
			else
				yeslang="$yeslang $x"
			fi
		done

		# shellcheck disable=SC1117
		filt="dash_\\(${filt:2}\\)\\.\(qm\|ts\)"
		sed "/${filt}/d" -i 'src/qt/dash_locale.qrc' || die
		# shellcheck disable=SC1117
		sed "s/locale\/${filt}/dash.qrc/" -i 'src/Makefile.qt.include' || die
		einfo "Languages -- Enabled:$yeslang -- Disabled:$nolang"
	fi

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
		$(use_enable hardened hardening)
		$(use_enable reduce-exports)
		$(use_enable test tests)
		$(use_enable wallet)
		$(use_enable zeromq zmq)
	)
	econf "${myeconf[@]}"
}

src_test() {
	emake -C src dash_test_check
}

src_install() {
	default

	if use daemon; then
		newinitd "${FILESDIR}/${PN}.initd" "${PN}"
		newconfd "${FILESDIR}/${PN}.confd" "${PN}"
		systemd_newunit "${FILESDIR}/${PN}.service-r1" "${PN}.service"

		insinto /etc/dash
		newins "${FILESDIR}/${PN}.conf" dash.conf
		fowners dash:dash /etc/dash/dash.conf
		fperms 600 /etc/dash/dash.conf
		newins contrib/debian/examples/dash.conf dash.conf.example
		doins share/rpcuser/rpcuser.py

		doman doc/man/dashd.1
		newbashcomp contrib/dashd.bash-completion dashd

		insinto /etc/logrotate.d
		newins "${FILESDIR}/${PN}.logrotate" "${PN}"
	fi

	if use gui; then
		local X
		for X in 16 32 64 128 256; do
			newicon -s ${X} "share/pixmaps/dash${X}.png" dash.png
		done
		# shellcheck disable=SC1117
		make_desktop_entry "dash-qt %u" "Dash Core" "dash" \
			"Qt;Network;P2P;Office;Finance;" \
			"MimeType=x-scheme-handler/dash;\nTerminal=false"

		doman doc/man/dash-qt.1
	fi

	use utils && doman doc/man/dash-{cli,tx}.1
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
