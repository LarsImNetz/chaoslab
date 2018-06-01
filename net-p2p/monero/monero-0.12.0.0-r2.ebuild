# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils systemd user

DESCRIPTION="The secure, private and untraceable cryptocurrency"
HOMEPAGE="https://getmonero.org"
SRC_URI="https://github.com/monero-project/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+daemon doc dot libressl readline +simplewallet unwind utils"
REQUIRED_USE="dot? ( doc )"

CDEPEND="app-arch/xz-utils
	dev-libs/boost:0=[nls,threads(+)]
	dev-libs/expat
	dev-libs/libsodium
	net-dns/unbound[threads]
	net-libs/cppzmq
	net-libs/ldns
	net-libs/miniupnpc
	sys-apps/pcsc-lite
	!libressl? ( dev-libs/openssl:0=[-bindist] )
	libressl? ( dev-libs/libressl:0= )
	readline? ( sys-libs/readline:0= )
	unwind? ( sys-libs/libunwind )"
DEPEND="${CDEPEND}
	doc? ( app-doc/doxygen[dot?] )"
RDEPEND="${CDEPEND}
	daemon? ( !net-p2p/monero-gui[daemon] )
	simplewallet? ( !net-p2p/monero-gui[simplewallet] )
	utils? ( !net-p2p/monero-gui[utils] )"

PATCHES=( "${FILESDIR}/${P}-fix_cmake.patch" )

pkg_setup() {
	if use daemon; then
		enewgroup monero
		enewuser monero -1 -1 /var/lib/monero monero
	fi
}

src_configure() {
	# shellcheck disable=SC2191,SC2207
	local mycmakeargs=(
		-DBUILD_DOCUMENTATION=$(usex doc ON OFF)
		-DSTACK_TRACE=$(usex unwind ON OFF)
		-DUSE_READLINE=$(usex readline ON OFF)
	)
	cmake-utils_src_configure
}

src_compile() {
	use daemon && \
		emake -C "${BUILD_DIR}"/src/daemon

	if use simplewallet; then
		emake -C "${BUILD_DIR}"/src/simplewallet
		emake -C "${BUILD_DIR}"/src/wallet
	fi

	use utils && \
		emake -C "${BUILD_DIR}"/src/blockchain_utilities

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
		dobin monero-wallet-cli
		dobin monero-wallet-rpc
	fi

	if use utils; then
		dobin monero-blockchain-export
		dobin monero-blockchain-import
	fi
	popd || die

	if use doc; then
		docinto html
		dodoc -r doc/html/*
	fi
}

pkg_postinst() {
	if use daemon; then
		if [ ! -e "${EROOT%/}"/etc/monero/monerod.conf ]; then
			elog "No monerod.conf found, copying the example over"
			cp "${EROOT%/}"/etc/monero/monerod.conf{.example,} || die
		fi
	fi
}
