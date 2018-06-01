# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils gnome2-utils qmake-utils systemd user

MO_GUI_COMMIT="b40363c"
MO_PV="aa6850c71d2269bd0728ee503ff07f1d52ce5e58" # tag v0.12.1.0
MO_URI="https://github.com/monero-project/monero/archive/${MO_PV}.tar.gz"
MO_P="monero-${MO_PV}"

# Keep this in sync with ../monero/external/{miniupnp,unbound}
MINIUPNP_COMMIT="6a63f9954959119568fbc4af57d7b491b9428d87"
UNBOUND_COMMIT="193bdc4ee3fe2b0d17e547e86512528c2614483a"
MINIUPNP_P="miniupnp-${MINIUPNP_COMMIT}"
UNBOUND_P="unbound-${UNBOUND_COMMIT}"

DESCRIPTION="The secure, private and untraceable cryptocurrency (with GUI wallet)"
HOMEPAGE="https://getmonero.org"
SRC_URI="https://github.com/monero-project/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${MO_URI} -> ${MO_P}.tar.gz
	https://github.com/monero-project/miniupnp/archive/${MINIUPNP_COMMIT}.tar.gz -> ${MINIUPNP_P}.tar.gz
	!system-unbound? ( https://github.com/monero-project/unbound/archive/${UNBOUND_COMMIT}.tar.gz -> ${UNBOUND_P}.tar.gz )"
RESTRICT="mirror"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+daemon doc dot +gui libressl readline scanner simplewallet +system-unbound unwind utils"
REQUIRED_USE="dot? ( doc ) scanner? ( gui )"

CDEPEND="app-arch/xz-utils
	dev-libs/boost:0=[nls,threads(+)]
	dev-libs/expat
	dev-libs/libsodium
	net-libs/cppzmq
	net-libs/ldns
	net-libs/miniupnpc
	sys-apps/pcsc-lite
	gui? (
		dev-qt/qtwidgets:5
		dev-qt/qtdeclarative:5[xml]
		dev-qt/qtquickcontrols:5
		dev-qt/qtquickcontrols2:5
		scanner? (
			dev-qt/qtmultimedia:5[qml]
			media-gfx/zbar
		)
	)
	!libressl? ( dev-libs/openssl:0=[-bindist] )
	libressl? ( dev-libs/libressl:0= )
	readline? ( sys-libs/readline:0= )
	system-unbound? ( net-dns/unbound[threads] )
	unwind? ( sys-libs/libunwind )"
DEPEND="${CDEPEND}
	doc? ( app-doc/doxygen[dot?] )
	gui? ( dev-qt/linguist-tools )"
RDEPEND="${CDEPEND}
	daemon? ( !net-p2p/monero[daemon] )
	simplewallet? ( !net-p2p/monero[simplewallet] )
	utils? ( !net-p2p/monero[utils] )"

PATCHES=( "${FILESDIR}/${P}-fix_cmake.patch" )

CMAKE_USE_DIR="${S}/monero"
BUILD_DIR="${CMAKE_USE_DIR}/build/release"

pkg_setup() {
	if use daemon; then
		enewgroup monero
		enewuser monero -1 -1 /var/lib/monero monero
	fi
}

src_prepare() {
	rmdir "${CMAKE_USE_DIR}" || die
	mv "${WORKDIR}/${MO_P}" "${CMAKE_USE_DIR}" || die

	mkdir -p "${S}/build" "${BUILD_DIR}" || die

	rmdir monero/external/{miniupnp,unbound} || die
	# Move dependencies
	mv "${WORKDIR}/${MINIUPNP_P}" monero/external/miniupnp || die
	if ! use system-unbound; then
		mv "${WORKDIR}/${UNBOUND_P}" monero/external/unbound || die
	fi

	# shellcheck disable=SC2086
	# Fix hardcoded translations path
	sed -i 's:"/translations":"/../share/'${PN}'/translations":' \
		TranslationManager.cpp || die "sed fix failed"

	cmake-utils_src_prepare
}

src_configure() {
	if use gui; then
		echo "var GUI_VERSION = \"${MO_GUI_COMMIT}\"" > version.js || die
		echo "var GUI_MONERO_VERSION = \"${MO_PV:0:7}\"" >> version.js || die

		pushd "${S}"/build || die
		eqmake5 ../monero-wallet-gui.pro \
			"CONFIG+=release \
			$(usex !scanner '' WITH_SCANNER) \
			$(usex unwind '' libunwind_off)"
		popd || die
	fi

	# shellcheck disable=SC2191,SC2207
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="${CMAKE_USE_DIR}"
		-DBUILD_DOCUMENTATION=$(usex doc ON OFF)
		-DBUILD_GUI_DEPS=ON
		-DINSTALL_VENDORED_LIBUNBOUND=$(usex system-unbound OFF ON)
		-DSTACK_TRACE=$(usex unwind ON OFF)
		-DUSE_READLINE=$(usex readline ON OFF)
	)
	cmake-utils_src_configure
}

src_compile() {
	pushd "${BUILD_DIR}"/src/wallet || die
	emake version -C ../..
	emake && emake install
	popd || die

	emake -C "${BUILD_DIR}"/contrib/epee all install
	emake -C "${BUILD_DIR}"/external/easylogging++ all install
	emake -C "${BUILD_DIR}"/external/db_drivers/liblmdb all install

	use daemon && emake -C "${BUILD_DIR}"/src/daemon
	use simplewallet && emake -C "${BUILD_DIR}"/src/simplewallet
	use utils && emake -C "${BUILD_DIR}"/src/blockchain_utilities
	use gui && emake -C src/zxcvbn-c && emake -C build

	if use doc; then
		pushd "${CMAKE_USE_DIR}" || die
		HAVE_DOT=$(usex dot) doxygen Doxyfile
		popd || die
	fi
}

src_install() {
	if use gui; then
		dobin build/release/bin/monero-wallet-gui

		# Install icons and desktop entry
		local X
		for X in 16 24 32 48 64 96 128 256; do
			newicon -s ${X} "images/appicons/${X}x${X}.png" monero.png
		done
		# shellcheck disable=SC1117
		make_desktop_entry "monero-wallet-gui %u" \
			"Monero Wallet" monero \
			"Qt;Network;P2P;Office;Finance;" \
			"MimeType=x-scheme-handler/monero;\nTerminal=false"

		insinto "/usr/share/${PN}/translations"
		for lang in build/translations/*.qm; do
			doins "${lang}"
		done
	fi

	pushd "${BUILD_DIR}"/bin || die
	if use daemon; then
		dobin monerod

		newinitd "${FILESDIR}/${PN}.initd" monero
		systemd_newunit "${FILESDIR}/${PN}.service" monero.service

		insinto /etc/monero
		newins "${S}"/monero/utils/conf/monerod.conf monerod.conf.example

		diropts -o monero -g monero -m 0750
		keepdir /var/log/monero
	fi

	use simplewallet && dobin monero-wallet-cli

	if use utils; then
		dobin monero-blockchain-export
		dobin monero-blockchain-import
	fi
	popd || die

	if use doc; then
		docinto html
		dodoc -r "${CMAKE_USE_DIR}"/doc/html/*
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
	if use daemon; then
		if [ ! -e "${EROOT%/}"/etc/monero/monerod.conf ]; then
			elog "No monerod.conf found, copying the example over"
			cp "${EROOT%/}"/etc/monero/monerod.conf{.example,} || die
		fi
	fi
}

pkg_postrm() {
	use gui && update_caches
}
