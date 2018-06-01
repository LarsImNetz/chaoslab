# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit golang-vcs-snapshot systemd user

EGO_PN="github.com/Shopify/${PN}"
DESCRIPTION="A TCP proxy to simulate network and system conditions"
HOMEPAGE="https://github.com/Shopify/toxiproxy"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="mirror strip"

DOCS=( {CHANGELOG,README}.md )

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup toxiproxy
	enewuser toxiproxy -1 -1 -1 toxiproxy
}

src_compile() {
	export GOPATH="${G}"
	local GOLDFLAGS="-s -w \
		-X ${EGO_PN}.Version=${PV}"

	go build -v -ldflags "${GOLDFLAGS}" \
		-o "${S}"/toxiproxy-server ./cmd || die

	go build -v -ldflags "${GOLDFLAGS}" \
		-o "${S}"/toxiproxy-cli ./cli || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin toxiproxy-{server,cli}
	einstalldocs

	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	systemd_dounit "${FILESDIR}"/${PN}.service
}
