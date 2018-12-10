# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils gnome2-utils qmake-utils systemd user

MO_PV="29073f65e8816d4c32b6ffef514943a5650b8d3b" # tag v0.13.0.4
MO_P="monero-${MO_PV}"

# Keep this in sync with ../monero/external/{miniupnp,rapidjson}
MINIUPNP_COMMIT="6a63f9954959119568fbc4af57d7b491b9428d87"
RAPIDJSON_COMMIT="129d19ba7f496df5e33658527a7158c79b99c21c"
UNBOUND_COMMIT="7f23967954736dcaa366806b9eaba7e2bdfede11"
MINIUPNP_P="miniupnp-${MINIUPNP_COMMIT}"
RAPIDJSON_P="rapidjson-${RAPIDJSON_COMMIT}"
UNBOUND_P="unbound-${UNBOUND_COMMIT}"

DESCRIPTION="The secure, private and untraceable cryptocurrency (with GUI wallet)"
HOMEPAGE="https://getmonero.org"
SRC_URI="
	https://github.com/monero-project/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/monero-project/monero/archive/${MO_PV}.tar.gz -> ${MO_P}.tar.gz
	https://github.com/monero-project/miniupnp/archive/${MINIUPNP_COMMIT}.tar.gz -> ${MINIUPNP_P}.tar.gz
	https://github.com/Tencent/rapidjson/archive/${RAPIDJSON_COMMIT}.tar.gz -> ${RAPIDJSON_P}.tar.gz
	https://github.com/monero-project/unbound/archive/${UNBOUND_COMMIT}.tar.gz -> ${UNBOUND_P}.tar.gz
"
RESTRICT="mirror"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+daemon doc dot libressl readline scanner simplewallet unwind utils xml"
REQUIRED_USE="dot? ( doc )"

CDEPEND="
	dev-libs/boost:0=[nls,threads(+)]
	dev-libs/hidapi
	dev-libs/libsodium
	dev-qt/qtdeclarative:5[widgets,xml]
	dev-qt/qtquickcontrols:5[widgets]
	dev-qt/qtquickcontrols2:5[widgets]
	net-dns/unbound:=[threads]
	net-libs/cppzmq
	!libressl? ( dev-libs/openssl:0=[-bindist] )
	libressl? ( dev-libs/libressl:0= )
	readline? ( sys-libs/readline:0= )
	scanner? (
		dev-qt/qtmultimedia:5[qml]
		media-gfx/zbar
	)
	unwind? (
		app-arch/xz-utils
		|| ( sys-libs/llvm-libunwind sys-libs/libunwind )
	)
	xml? ( dev-libs/expat )
"
DEPEND="${CDEPEND}
	dev-qt/linguist-tools:5
	doc? ( app-doc/doxygen[dot?] )
"
RDEPEND="${CDEPEND}
	daemon? ( !net-p2p/monero[daemon] )
	simplewallet? ( !net-p2p/monero[simplewallet] )
	utils? ( !net-p2p/monero[utils] )
"

CMAKE_BUILD_TYPE="Release"
CMAKE_USE_DIR="${S}/monero"
BUILD_DIR="${CMAKE_USE_DIR}/build/release"

pkg_setup() {
	if use daemon; then
		enewgroup monero
		enewuser monero -1 -1 /var/lib/monero monero
	fi
}

src_unpack() {
	unpack "${P}.tar.gz"
	cd "${S}" || die
	unpack "${MO_P}.tar.gz"
	unpack "${MINIUPNP_P}.tar.gz"
	unpack "${RAPIDJSON_P}.tar.gz"
	unpack "${UNBOUND_P}.tar.gz"
}

src_prepare() {
	rmdir "${CMAKE_USE_DIR}" || die
	mv "${MO_P}" "${CMAKE_USE_DIR}" || die

	mkdir -p "${S}/build" "${BUILD_DIR}" || die

	rmdir monero/external/{miniupnp,rapidjson,unbound} || die
	mv "${MINIUPNP_P}" monero/external/miniupnp || die
	mv "${RAPIDJSON_P}" monero/external/rapidjson || die
	mv "${UNBOUND_P}" monero/external/unbound || die

	# Fix hardcoded translations path
	#sed -i "s|/translations\"|/../share/${PN}/translations\"|" \
	#	TranslationManager.cpp || die

	cmake-utils_src_prepare
}

src_configure() {
	echo "GUI_MONERO_VERSION=\"v${PV}\"" > monero/version.sh || die
	echo "var GUI_VERSION = \"v${PV}\"" > version.js || die
	echo "var GUI_MONERO_VERSION = \"v${PV}\"" >> version.js || die

	# shellcheck disable=SC2191,SC2207
	local mycmakeargs=(
		-DINSTALL_VENDORED_LIBUNBOUND=ON
		-DCMAKE_INSTALL_PREFIX="${CMAKE_USE_DIR}"
		-DBUILD_DOCUMENTATION=$(usex doc ON OFF)
		-DBUILD_GUI_DEPS=ON
		-DMANUAL_SUBMODULES=ON
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

	if use simplewallet; then
		emake -C "${BUILD_DIR}"/src/gen_multisig
		emake -C "${BUILD_DIR}"/src/simplewallet
		emake -C "${BUILD_DIR}"/src/wallet
	fi

	use utils && emake -C "${BUILD_DIR}"/src/blockchain_utilities

	# build zxcvbn (pass strength meter)
	emake -C src/zxcvbn-c

	# shellcheck disable=SC2207
	# build up optional flags
	local options=(
		$(usex !scanner '' WITH_SCANNER)
		$(usex unwind '' libunwind_off)
	)

	pushd "${S}"/build || die
	eqmake5 ../monero-wallet-gui.pro "CONFIG+=release ${options[*]}"
	emake
	popd || die

	if use doc; then
		pushd "${CMAKE_USE_DIR}" || die
		HAVE_DOT=$(usex dot) doxygen Doxyfile
		popd || die
	fi
}

src_install() {
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

	#local lang
	#insinto "/usr/share/${PN}/translations"
	#for lang in build/translations/*.qm; do
	#	doins "${lang}"
	#done

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

	if use simplewallet; then
		dobin monero-gen-trusted-multisig
		dobin monero-wallet-cli
		dobin monero-wallet-rpc
	fi

	if use utils; then
		dobin monero-blockchain-ancestry
		dobin monero-blockchain-depth
		dobin monero-blockchain-export
		dobin monero-blockchain-import
		dobin monero-blockchain-mark-spent-outputs
		dobin monero-blockchain-usage
	fi
	popd || die

	if use doc; then
		docinto html
		dodoc -r "${CMAKE_USE_DIR}"/doc/html/*
	fi
}

pkg_preinst() {
	gnome2_icon_savelist
}

update_caches() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}

pkg_postinst() {
	update_caches
	if use daemon; then
		if [[ ! -e "${EROOT%/}/etc/monero/monerod.conf" ]]; then
			elog "No monerod.conf found, copying the example over"
			cp "${EROOT%/}"/etc/monero/monerod.conf{.example,} || die
		fi
	fi
}

pkg_postrm() {
	update_caches
}
