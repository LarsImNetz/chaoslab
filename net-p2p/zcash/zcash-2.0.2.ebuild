# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit bash-completion-r1 flag-o-matic systemd user

# depends/packages/bdb.mk (http://www.oracle.com, AGPL-3 license)
BDB_PV="6.2.23"
BDB_PKG="db-${BDB_PV}.tar.gz"
BDB_HASH="47612c8991aa9ac2f6be721267c8d3cdccf5ac83105df8e50809daea24e95dc7"
BDB_URI="https://download.oracle.com/berkeley-db/${BDB_PKG}"
BDB_STAMP=".stamp_fetched-bdb-${BDB_PKG}.hash"

# depends/packages/openssl.mk (https://www.openssl.org, openssl license)
OPENSSL_PV="1.1.0h"
OPENSSL_PKG="openssl-${OPENSSL_PV}.tar.gz"
OPENSSL_HASH="5835626cde9e99656585fc7aaa2302a73a7e1340bf8c14fd635a62c66802a517"
OPENSSL_URI="https://www.openssl.org/source/${OPENSSL_PKG}"
OPENSSL_STAMP=".stamp_fetched-openssl-${OPENSSL_PKG}.hash"

# depends/packages/proton.mk (https://qpid.apache.org/proton/, Apache 2.0 license)
PROTON_PV="0.17.0"
PROTON_PKG="qpid-proton-${PROTON_PV}.tar.gz"
PROTON_HASH="6ffd26d3d0e495bfdb5d9fefc5349954e6105ea18cc4bb191161d27742c5a01a"
PROTON_URI="https://archive.apache.org/dist/qpid/proton/${PROTON_PV}/${PROTON_PKG}"
PROTON_STAMP=".stamp_fetched-proton-${PROTON_PKG}.hash"

# depends/packages/librustzcash.mk (https://github.com/zcash/librustzcash, Apache 2.0 / MIT license)
RUSTZCASH_PV="06da3b9ac8f278e5d4ae13088cf0a4c03d2c13f5"
RUSTZCASH_PKG="librustzcash-${RUSTZCASH_PV}.tar.gz"
RUSTZCASH_HASH="9909ec59fa7a411c2071d6237b3363a0bc6e5e42358505cf64b7da0f58a7ff5a"
RUSTZCASH_URI="https://github.com/zcash/librustzcash/archive/${RUSTZCASH_PV}.tar.gz"
RUSTZCASH_STAMP=".stamp_fetched-librustzcash-${RUSTZCASH_PKG}.hash"

# depends/packages/crate_blake2_rfc.mk (https://github.com/gtank/blake2-rfc, Apache 2.0 / MIT license)
CRATE_BLAKE2_PV="7a5b5fc99ae483a0043db7547fb79a6fa44b88a9"
CRATE_BLAKE2_PKG="crate_blake2_rfc-${CRATE_BLAKE2_PV}.tar.gz"
CRATE_BLAKE2_HASH="8a873cc41f02e669e8071ab5919931dd4263f050becf0c19820b0497c07b0ca3"
CRATE_BLAKE2_URI="https://github.com/gtank/blake2-rfc/archive/${CRATE_BLAKE2_PV}.tar.gz"
CRATE_BLAKE2_STAMP=".stamp_fetched-crate_blake2_rfc-${CRATE_BLAKE2_PKG}.hash"

# depends/packages/crate_sapling_crypto.mk (https://github.com/zcash-hackworks/sapling-crypto, Apache 2.0 / MIT license)
CRATE_SAPLING_CRYPTO_PV="21084bde2019c04bd34208e63c3560fe2c02fb0e"
CRATE_SAPLING_CRYPTO_PKG="crate_sapling_crypto-${CRATE_SAPLING_CRYPTO_PV}.tar.gz"
CRATE_SAPLING_CRYPTO_HASH="ae3a122b1f1ce97b4e80e0e8542e19aa1516e99e6c72875688c886af1a881558"
CRATE_SAPLING_CRYPTO_URI="https://github.com/zcash-hackworks/sapling-crypto/archive/${CRATE_SAPLING_CRYPTO_PV}.tar.gz"
CRATE_SAPLING_CRYPTO_STAMP=".stamp_fetched-crate_sapling_crypto-${CRATE_SAPLING_CRYPTO_PKG}.hash"

# depends/packages/crate_zip32.mk (https://github.com/zcash-hackworks/zip32, Apache 2.0 / MIT license)
CRATE_ZIP32_PV="176470ef41583b5bd0bd749bd1b61d417aa8ec79"
CRATE_ZIP32_PKG="crate_zip32-${CRATE_ZIP32_PV}.tar.gz"
CRATE_ZIP32_HASH="b0b011ea96524f0d918a44c7ab8a3dec6270879d1ff03d7dbda6c676d25caa7e"
CRATE_ZIP32_URI="https://github.com/zcash-hackworks/zip32/archive/${CRATE_ZIP32_PV}.tar.gz"
CRATE_ZIP32_STAMP=".stamp_fetched-crate_zip32-${CRATE_ZIP32_PKG}.hash"

# depends/packages/crate_*.mk
CRATE_DEP=(
	"aes 0.2.0 e6fb1737cdc8da3db76e90ca817a194249a38fcb500c2e6ecec39b29448aa873"
	"aes-soft 0.2.0 67cc03b0a090a05cb01e96998a01905d7ceedce1bc23b756c0bb7faa0682ccb1"
	"aesni 0.4.1 6810b7fb9f2bb4f76f05ac1c170b8dde285b6308955dc3afd89710268c958d9e"
	"arrayvec 0.4.7 a1e964f9e24d588183fcb43503abda40d288c8657dfc27311516ce2f05675aef"
	"bellman 0.1.0 eae372472c7ea8f7c8fc6a62f7d5535db8302de7f1aafda2e13a97c4830d3bcf"
	"bit-vec 0.4.4 02b4ff8b16e6076c3e14220b39fbc1fabb6737522281a388998046859400895f"
	"bitflags 1.0.1 b3c30d3802dfb7281680d6285f2ccdaa8c2d8fee41f93805dba5c4cf50dc23cf"
	"block-cipher-trait 0.5.3 370424437b9459f3dfd68428ed9376ddfe03d8b70ede29cc533b3557df186ab4"
	"byte-tools 0.2.0 560c32574a12a89ecd91f5e742165893f86e3ab98d21f8ea548658eb9eef5f40"
	"byteorder 1.2.2 73b5bdfe7ee3ad0b99c9801d58807a9dbc9e09196365b0203853b99889ab3c87"
	"constant_time_eq 0.1.3 8ff012e225ce166d4422e0e78419d901719760f62ae2b7969ca6b564d1b54a9e"
	"crossbeam 0.3.2 24ce9782d4d5c53674646a6a4c1863a21a8fc0cb649b3c94dfc16e45071dea19"
	"digest 0.7.2 00a49051fef47a72c9623101b19bd71924a45cca838826caae3eaa4d00772603"
	"fpe 0.1.0 ce3371c82bfbd984f624cab093f55e7336f5a6e589f8518e1258f54f011b89ad"
	"fuchsia-zircon 0.3.3 2e9763c69ebaae630ba35f74888db465e49e259ba1bc0eda7d06f4a067615d82"
	"fuchsia-zircon-sys 0.3.3 3dcaa9ae7725d12cdb85b3ad99a434db70b468c09ded17e012d86b5c1010f7a7"
	"futures 0.1.21 1a70b146671de62ec8c8ed572219ca5d594d9b06c0b364d5e67b722fc559b48c"
	"futures-cpupool 0.1.8 ab90cde24b3319636588d0c35fe03b1333857621051837ed769faefb4c2162e4"
	"generic-array 0.9.0 ef25c5683767570c2bbd7deba372926a55eaae9982d7726ee2a1050239d45b9d"
	"lazy_static 1.0.0 c8f31047daa365f19be14b47c29df4f7c3b581832407daabe6ae77397619237d"
	"libc 0.2.40 6fd41f331ac7c5b8ac259b8bf82c75c0fb2e469bbf37d2becbba9a6a2221965b"
	"nodrop 0.1.12 9a2228dca57108069a5262f2ed8bd2e82496d2e074a06d1ccc7ce1687b6ae0a2"
	"num-bigint 0.2.0 3eceac7784c5dc97c2d6edf30259b4e153e6e2b42b3c85e9a6e9f45d06caef6e"
	"num_cpus 1.8.0 c51a3322e4bca9d212ad9a158a02abc6934d005490c054a2778df73a70aa0a30"
	"num-integer 0.1.39 e83d528d2677f0518c570baf2b7abdcf0cd2d248860b68507bdcb3e91d4c0cea"
	"num-traits 0.2.5 630de1ef5cc79d0cdd78b7e33b81f083cbfe90de0f4b2b2f07f905867c70e9fe"
	"opaque-debug 0.1.1 d620c9c26834b34f039489ac0dfdb12c7ac15ccaf818350a64c9b5334a452ad7"
	"pairing 0.14.2 ceda21136251c6d5a422d3d798d8ac22515a6e8d3521bb60c59a8349d36d0d57"
	"rand 0.4.2 eba5f8cb59cc50ed56be8880a5c7b496bfd9bd26394e176bc67884094145c2c5"
	"stream-cipher 0.1.1 30dc6118470d69ce0fdcf7e6f95e95853f7f4f72f80d835d4519577c323814ab"
	"typenum 1.10.0 612d636f949607bdf9b123b4a6f6d966dedf3ff669f7f045890d3a4a73948169"
	"winapi 0.3.4 04e3bd221fcbe8a271359c04f21a76db7d0c6028862d1bb5512d85e1e2eb5bb3"
	"winapi-i686-pc-windows-gnu 0.4.0 ac3b87c63620426dd9b991e5ce0329eff545bccbbb34f3be09ff6fb6ab51b7b6"
	"winapi-x86_64-pc-windows-gnu 0.4.0 712e227841d057c1ee1cd2fb22fa7e5a5461ae8e48fa2ca79ec42cfc1931183f"
)

MY_PV="${PV/_/-}"
DESCRIPTION="Cryptocurrency that offers privacy of transactions"
HOMEPAGE="https://z.cash"
SRC_URI="
	https://github.com/${PN}/${PN}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz
	${BDB_URI}
	${CRATE_BLAKE2_URI} -> ${CRATE_BLAKE2_PKG}
	${CRATE_SAPLING_CRYPTO_URI} -> ${CRATE_SAPLING_CRYPTO_PKG}
	${CRATE_ZIP32_URI} -> ${CRATE_ZIP32_PKG}
	${RUSTZCASH_URI} -> ${RUSTZCASH_PKG}
	bundled-ssl? ( ${OPENSSL_URI} )
	proton? ( ${PROTON_URI} )
"
# shellcheck disable=SC2206
for c in "${CRATE_DEP[@]}"; do
	c=(${c})
	SRC_URI+=" https://crates.io/api/v1/crates/${c[0]}/${c[1]}/download -> ${c[0]}-${c[1]}.crate"
done
unset c
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+bundled-ssl examples +hardened libressl libs mining proton +reduce-exports zeromq"

REQUIRED_USE="bundled-ssl? ( !libressl )"

RDEPEND="
	dev-libs/boost:0=[threads(+)]
	dev-libs/gmp:0
	dev-libs/libevent
	dev-libs/libsodium:0=[-minimal]
	!bundled-ssl? (
		!libressl? ( dev-libs/openssl:0=[-bindist] )
		libressl? ( dev-libs/libressl:0= )
	)
	zeromq? ( >=net-libs/zeromq-4.2.1 )
"
DEPEND="${RDEPEND}
	>=dev-cpp/gtest-1.8.0
	virtual/rust
"

PATCHES=( "${FILESDIR}/${PN}-2.0.1-no_gtest.patch" )
DOCS=( doc/{payment-api,security-warnings,tor}.md )

S="${WORKDIR}/${PN}-${MY_PV}"

pkg_setup() {
	enewgroup zcash
	enewuser zcash -1 -1 /var/lib/zcashd zcash
}

src_unpack() {
	# Unpack only the main source
	unpack "${P}".tar.gz
}

src_prepare() {
	default

	local DEP_SRC STAMP_DIR LIBS c
	local native_packages packages
	DEP_SRC="${S}/depends/sources"
	STAMP_DIR="${DEP_SRC}/download-stamps"

	# Prepare download-stamps
	mkdir -p "${STAMP_DIR}" || die
	echo "${BDB_HASH} ${BDB_PKG}" > "${STAMP_DIR}/${BDB_STAMP}" || die
	echo "${CRATE_BLAKE2_HASH} ${CRATE_BLAKE2_PKG}" > "${STAMP_DIR}/${CRATE_BLAKE2_STAMP}" || die
	echo "${CRATE_SAPLING_CRYPTO_HASH} ${CRATE_SAPLING_CRYPTO_PKG}" > "${STAMP_DIR}/${CRATE_SAPLING_CRYPTO_STAMP}" || die
	echo "${CRATE_ZIP32_HASH} ${CRATE_ZIP32_PKG}" > "${STAMP_DIR}/${CRATE_ZIP32_STAMP}" || die
	echo "${RUSTZCASH_HASH} ${RUSTZCASH_PKG}" > "${STAMP_DIR}/${RUSTZCASH_STAMP}" || die
	# shellcheck disable=SC2206
	for c in "${CRATE_DEP[@]}"; do
		c=(${c})
		echo "${c[2]} ${c[0]}-${c[1]}.crate" > "${STAMP_DIR}/.stamp_fetched-crate_${c[0]//-/_}-${c[0]}-${c[1]}.crate.hash" || die
	done

	# Symlink dependencies
	ln -s "${DISTDIR}/${BDB_PKG}" "${DEP_SRC}" || die
	ln -s "${DISTDIR}/${CRATE_BLAKE2_PKG}" "${DEP_SRC}" || die
	ln -s "${DISTDIR}/${CRATE_SAPLING_CRYPTO_PKG}" "${DEP_SRC}" || die
	ln -s "${DISTDIR}/${CRATE_ZIP32_PKG}" "${DEP_SRC}" || die
	ln -s "${DISTDIR}/${RUSTZCASH_PKG}" "${DEP_SRC}" || die
	# shellcheck disable=SC2206
	for c in "${CRATE_DEP[@]}"; do
		c=(${c})
		ln -s "${DISTDIR}/${c[0]}-${c[1]}.crate" "${DEP_SRC}" || die
	done

	if use bundled-ssl; then
		echo "${OPENSSL_HASH} ${OPENSSL_PKG}" > "${STAMP_DIR}/${OPENSSL_STAMP}" || die
		ln -s "${DISTDIR}"/${OPENSSL_PKG} "${DEP_SRC}" || die
	fi

	if use proton; then
		echo "${PROTON_HASH} ${PROTON_PKG}" > "${STAMP_DIR}/${PROTON_STAMP}" || die
		ln -s "${DISTDIR}"/${PROTON_PKG} "${DEP_SRC}" || die
	fi

	# No need to build the bundled rust
	sed -i 's:rust ::' depends/packages/librustzcash.mk || die

	ebegin "Building bundled dependencies"
	pushd depends || die
	# shellcheck disable=SC2206
	for c in "${CRATE_DEP[@]//-/_}"; do
		c=(${c})
		packages="${packages} crate_${c[0]}"
	done
	make install native_packages="" \
		packages="bdb crate_blake2_rfc \
			crate_sapling_crypto \
			crate_zip32 \
			${packages} librustzcash \
			$(usex bundled-ssl openssl '') \
			$(usex proton proton '')" || die
	popd || die
	eend $?

	./autogen.sh || die
}

src_configure() {
	local BUILD depends_prefix
	BUILD="$(./depends/config.guess)"
	append-cppflags "-I${S}/depends/${BUILD}/include"
	append-ldflags "-L${S}/depends/${BUILD}/lib"

	# shellcheck disable=SC2207,SC2191
	local myeconf=(
		depends_prefix="${S}/depends/${BUILD}"
		--prefix="${EPREFIX}"/usr
		--disable-ccache
		--disable-tests
		$(use_enable hardened hardening)
		$(use_enable mining)
		$(use_enable proton)
		$(use_enable reduce-exports)
		$(use_enable zeromq zmq)
		$(use_with libs)
	)
	econf "${myeconf[@]}"
}

src_install() {
	default

	newinitd "${FILESDIR}"/zcash.initd zcash
	newconfd "${FILESDIR}"/zcash.confd zcash
	systemd_newunit "${FILESDIR}"/zcash.service-r1 zcash.service

	insinto /etc/zcash
	doins "${FILESDIR}"/zcash.conf
	fowners zcash:zcash /etc/zcash/zcash.conf
	fperms 0600 /etc/zcash/zcash.conf
	newins contrib/debian/examples/zcash.conf zcash.conf.example

	local x
	for x in -cli -tx d; do
		newbashcomp "contrib/zcash${x}.bash-completion" "zcash${x}"
	done

	insinto /etc/logrotate.d
	newins "${FILESDIR}"/zcash.logrotate zcash

	if use examples; then
		docinto examples
		dodoc -r contrib/{bitrpc,qos,spendfrom}
		docompress -x "/usr/share/doc/${PF}/examples"
	fi
}

pkg_postinst() {
	ewarn
	ewarn "SECURITY WARNINGS:"
	ewarn "Zcash is experimental and a work-in-progress. Use at your own risk."
	ewarn
	ewarn "Please see important security warnings in"
	ewarn "${EROOT}/usr/share/doc/${P}/security-warnings.md.bz2"
	ewarn

	if [ -z "${REPLACING_VERSIONS}" ]; then
		einfo
		elog "You should manually fetch the parameters for all users:"
		elog "$ zcash-fetch-params"
		elog ""
		elog "This script will fetch the Zcash zkSNARK parameters and verify"
		elog "their integrity with sha256sum."
		elog ""
		elog "The parameters are currently just under 911MB in size, so plan accordingly"
		elog "for your bandwidth constraints. If the files are already present and"
		elog "have the correct sha256sum, no networking is used."
		einfo
	fi
}
