# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils systemd user

# Keep this in sync with external/{miniupnp,rapidjson}
MINIUPNP_PV="6b9b73a567e351b844f96c077f7b752ea92e298a"
RAPIDJSON_PV="129d19ba7f496df5e33658527a7158c79b99c21c"
MINIUPNP_P="miniupnp-${MINIUPNP_PV}"
RAPIDJSON_P="rapidjson-${RAPIDJSON_PV}"

DESCRIPTION="The secure, private and untraceable cryptocurrency"
HOMEPAGE="https://getmonero.org"
SRC_URI="
	https://github.com/monero-project/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/monero-project/miniupnp/archive/${MINIUPNP_PV}.tar.gz -> ${MINIUPNP_P}.tar.gz
	https://github.com/Tencent/rapidjson/archive/${RAPIDJSON_PV}.tar.gz -> ${RAPIDJSON_P}.tar.gz
"
RESTRICT="mirror"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+daemon doc dot libressl readline +simplewallet unwind utils xml"
REQUIRED_USE="dot? ( doc )"

CDEPEND="
	dev-libs/boost:0=[nls,threads(+)]
	dev-libs/hidapi
	dev-libs/libsodium
	net-dns/unbound:=[threads]
	net-libs/cppzmq
	!libressl? ( dev-libs/openssl:0=[-bindist] )
	libressl? ( dev-libs/libressl:0= )
	readline? ( sys-libs/readline:0= )
	unwind? (
		app-arch/xz-utils
		|| ( sys-libs/llvm-libunwind sys-libs/libunwind )
	)
	xml? ( dev-libs/expat )
"
DEPEND="${CDEPEND}
	doc? ( app-doc/doxygen[dot?] )
"
RDEPEND="${CDEPEND}
	daemon? ( !net-p2p/monero-gui[daemon] )
	simplewallet? ( !net-p2p/monero-gui[simplewallet] )
	utils? ( !net-p2p/monero-gui[utils] )
"

pkg_setup() {
	if use daemon; then
		enewgroup monero
		enewuser monero -1 -1 /var/lib/monero monero
	fi
}

src_unpack() {
	unpack "${P}.tar.gz"
	cd "${S}" || die
	unpack "${MINIUPNP_P}.tar.gz"
	unpack "${RAPIDJSON_P}.tar.gz"
}

src_prepare() {
	rmdir external/{miniupnp,rapidjson} || die

	# Move dependencies
	mv "${MINIUPNP_P}" external/miniupnp || die
	mv "${RAPIDJSON_P}" external/rapidjson || die

	cmake-utils_src_prepare
}

src_configure() {
	# shellcheck disable=SC2191,SC2207
	local mycmakeargs=(
		-DMANUAL_SUBMODULES=1
		-DBUILD_DOCUMENTATION=$(usex doc ON OFF)
		-DSTACK_TRACE=$(usex unwind ON OFF)
		-DUSE_READLINE=$(usex readline ON OFF)
	)
	cmake-utils_src_configure
}

src_compile() {
	use daemon && emake -C "${BUILD_DIR}"/src/daemon

	if use simplewallet; then
		emake -C "${BUILD_DIR}"/src/gen_multisig
		emake -C "${BUILD_DIR}"/src/simplewallet
		emake -C "${BUILD_DIR}"/src/wallet
	fi

	use utils && emake -C "${BUILD_DIR}"/src/blockchain_utilities

	if use doc; then
		pushd "${CMAKE_USE_DIR}" || die
		HAVE_DOT=$(usex dot) doxygen Doxyfile
		popd || die
	fi
}

src_install() {
	pushd "${BUILD_DIR}"/bin || die
	if use daemon; then
		dobin monerod

		newinitd "${FILESDIR}/${PN}.initd" "${PN}"
		systemd_dounit "${FILESDIR}/${PN}.service"

		insinto /etc/monero
		newins "${S}"/utils/conf/monerod.conf monerod.conf.example

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
		dodoc -r doc/html/*
	fi
}

pkg_postinst() {
	if use daemon; then
		if [[ ! -e "${EROOT%/}/etc/monero/monerod.conf" ]]; then
			elog "No monerod.conf found, copying the example over"
			cp "${EROOT%/}"/etc/monero/monerod.conf{.example,} || die
		fi
	fi
}
