# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

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
RUSTZCASH_PV="91348647a86201a9482ad4ad68398152dc3d635e"
RUSTZCASH_PKG="librustzcash-${RUSTZCASH_PV}.tar.gz"
RUSTZCASH_HASH="a5760a90d4a1045c8944204f29fa2a3cf2f800afee400f88bf89bbfe2cce1279"
RUSTZCASH_URI="https://github.com/zcash/librustzcash/archive/${RUSTZCASH_PV}.tar.gz"
RUSTZCASH_STAMP=".stamp_fetched-librustzcash-${RUSTZCASH_PKG}.hash"

# depends/packages/crate_libc.mk (https://github.com/rust-lang/libc, Apache 2.0 / MIT license)
CRATE_LIBC_PV="0.2.21"
CRATE_LIBC_PKG="libc-${CRATE_LIBC_PV}.crate"
CRATE_LIBC_HASH="88ee81885f9f04bff991e306fea7c1c60a5f0f9e409e99f6b40e3311a3363135"
CRATE_LIBC_URI="https://crates.io/api/v1/crates/libc/${CRATE_LIBC_PV}/download"
CRATE_LIBC_STAMP=".stamp_fetched-crate_libc-${CRATE_LIBC_PKG}.hash"

DESCRIPTION="Cryptocurrency that offers privacy of transactions"
HOMEPAGE="https://z.cash"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${BDB_URI}
	${CRATE_LIBC_URI} -> ${CRATE_LIBC_PKG}
	${RUSTZCASH_URI} -> ${RUSTZCASH_PKG}
	bundled-ssl? ( ${OPENSSL_URI} )
	proton? ( ${PROTON_URI} )"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="bundled-ssl examples +hardened libressl libs mining proton reduce-exports zeromq"

REQUIRED_USE="bundled-ssl? ( !libressl )"

RDEPEND="dev-libs/boost:0=[threads(+)]
	>=dev-libs/gmp-6.1.0
	>=dev-libs/libevent-2.1.8
	dev-libs/libsodium:0=[-minimal]
	!bundled-ssl? (
		!libressl? ( dev-libs/openssl:0=[-bindist] )
		libressl? ( dev-libs/libressl:0= )
	)
	zeromq? ( >=net-libs/zeromq-4.2.1 )"
DEPEND="${RDEPEND}
	>=dev-cpp/gtest-1.8.0
	>=virtual/rust-0.16.0"

PATCHES=( "${FILESDIR}/${P}-no_gtest.patch" )
DOCS=( doc/{payment-api,security-warnings,tor}.md )

pkg_setup() {
	enewgroup zcash
	enewuser zcash -1 -1 /var/lib/zcashd zcash
}

src_unpack() {
	# Unpack only the main source
	unpack "${P}".tar.gz
}

src_prepare() {
	local DEP_SRC STAMP_DIR LIBS X
	local native_packages packages
	DEP_SRC="${S}/depends/sources"
	STAMP_DIR="${DEP_SRC}/download-stamps"

	# Prepare download-stamps
	mkdir -p "${STAMP_DIR}" || die
	echo "${BDB_HASH} ${BDB_PKG}" > "${STAMP_DIR}/${BDB_STAMP}" || die
	echo "${CRATE_LIBC_HASH} ${CRATE_LIBC_PKG}" > "${STAMP_DIR}/${CRATE_LIBC_STAMP}" || die
	echo "${RUSTZCASH_HASH} ${RUSTZCASH_PKG}" > "${STAMP_DIR}/${RUSTZCASH_STAMP}" || die

	# Symlink dependencies
	ln -s "${DISTDIR}/${BDB_PKG}" "${DEP_SRC}" || die
	ln -s "${DISTDIR}/${CRATE_LIBC_PKG}" "${DEP_SRC}" || die
	ln -s "${DISTDIR}/${RUSTZCASH_PKG}" "${DEP_SRC}" || die

	if use bundled-ssl; then
		echo "${OPENSSL_HASH} ${OPENSSL_PKG}" > "${STAMP_DIR}/${OPENSSL_STAMP}" || die
		ln -s "${DISTDIR}"/${OPENSSL_PKG} "${DEP_SRC}" || die
	fi

	if use proton; then
		echo "${PROTON_HASH} ${PROTON_PKG}" > "${STAMP_DIR}/${PROTON_STAMP}" || die
		ln -s "${DISTDIR}"/${PROTON_PKG} "${DEP_SRC}" || die
	fi

	# There's no need to build the bundled rust
	sed -i 's:rust ::' depends/packages/librustzcash.mk || die

	ebegin "Building bundled dependencies"
	pushd depends || die
	make install \
		native_packages="" \
		packages="bdb crate_libc librustzcash \
			$(usex bundled-ssl openssl '') \
			$(usex proton proton '')" || die
	popd || die
	eend $?

	default
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
	systemd_newtmpfilesd "${FILESDIR}"/zcash.tmpfilesd-r2 zcash.conf

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
	ewarn "Please, see important security warnings in"
	ewarn "${EROOT%/}/usr/share/doc/${P}/security-warnings.md.bz2"
	ewarn
	if [ -z "${REPLACING_VERSIONS}" ]; then
		einfo
		elog "You should manually fetch the parameters for all users:"
		elog "$ zcash-fetch-params"
		elog
		elog "This script will fetch the Zcash zkSNARK parameters and verify"
		elog "their integrity with sha256sum."
		elog
		elog "The parameters are currently just under 911MB in size, so plan accordingly"
		elog "for your bandwidth constraints. If the files are already present and"
		elog "have the correct sha256sum, no networking is used."
		einfo
	fi
}
