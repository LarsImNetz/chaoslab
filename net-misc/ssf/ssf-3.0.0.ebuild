# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

# Keep this in sync with third_party/cxxopts
CXXOPTS_COMMIT="0b7686949d01f6475cc13ba0693725aefb76fc0c"
CXXOPTS_P="cxxopts-${CXXOPTS_COMMIT}"
# Keep this in sync with third_party/http-parser/http-parser
HTTP_PARSER_COMMIT="feae95a3a69f111bc1897b9048d9acbc290992f9"
HTTP_PARSER_P="http-parser-${HTTP_PARSER_COMMIT}"
# Keep this in sync with third_party/msgpack/msgpack-c
MSGPACK_COMMIT="7a98138f27f27290e680bf8fbf1f8d1b089bf138"
MSGPACK_P="msgpack-c-${MSGPACK_COMMIT}"
# Keep this in sync with third_party/spdlog/spdlog
SPDLOG_COMMIT="4fba14c79f356ae48d6141c561bf9fd7ba33fabd"
SPDLOG_P="spdlog-${SPDLOG_COMMIT}"

DESCRIPTION="A network toolkit for TCP/UDP port forwarding, SOCKS proxy and remote shell"
HOMEPAGE="https://securesocketfunneling.github.io/ssf/"
SRC_URI="https://github.com/securesocketfunneling/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/jarro2783/cxxopts/archive/${CXXOPTS_COMMIT}.tar.gz -> ${CXXOPTS_P}.tar.gz
	https://github.com/nodejs/http-parser/archive/${HTTP_PARSER_COMMIT}.tar.gz -> ${HTTP_PARSER_P}.tar.gz
	https://github.com/msgpack/msgpack-c/archive/${MSGPACK_COMMIT}.tar.gz -> ${MSGPACK_P}.tar.gz
	https://github.com/gabime/spdlog/archive/${SPDLOG_COMMIT}.tar.gz -> ${SPDLOG_P}.tar.gz
"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="libressl"

DEPEND="
	dev-libs/boost:0=[threads(+)]
	virtual/krb5
	!libressl? ( dev-libs/openssl:0= )
	libressl? ( dev-libs/libressl:0= )
"
RDEPEND="${DEPEND}"

PATCHES=( "${FILESDIR}/${P}-libressl.patch" )

src_prepare() {
	rmdir third_party/cxxopts || die
	rmdir third_party/http-parser/http-parser || die
	rmdir third_party/msgpack/msgpack-c || die
	rmdir third_party/spdlog/spdlog || die

	# Move dependencies
	mv "${WORKDIR}/${CXXOPTS_P}" third_party/cxxopts || die
	mv "${WORKDIR}/${HTTP_PARSER_P}" third_party/http-parser/http-parser || die
	mv "${WORKDIR}/${MSGPACK_P}" third_party/msgpack/msgpack-c || die
	mv "${WORKDIR}/${SPDLOG_P}" third_party/spdlog/spdlog || die

	# No need to install test certificates
	sed -i "/TEST_CERT_/d" ./CMakeLists.txt || die

	cmake-utils_src_prepare
}

src_install() {
	cmake-utils_src_install

	newinitd "${FILESDIR}/${PN}.initd" ssfd
	newconfd "${FILESDIR}/${PN}.confd" ssfd

	dodir /etc/ssf
}
