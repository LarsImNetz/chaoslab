# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/Shopify/${PN}"

inherit golang-vcs-snapshot systemd user

DESCRIPTION="A TCP proxy to simulate network and system conditions"
HOMEPAGE="https://github.com/Shopify/toxiproxy"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="pie"

DOCS=( {CHANGELOG,README}.md )
QA_PRESTRIPPED="usr/bin/toxiproxy-cli
	usr/bin/toxiproxy-server"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup toxiproxy
	enewuser toxiproxy -1 -1 -1 toxiproxy
}

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w -X ${EGO_PN}.Version=${PV}"
	)
	go build "${mygoargs[@]}" -o ./toxiproxy-cli ./cli  || die
	go build "${mygoargs[@]}" -o ./toxiproxy-server ./cmd  || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin toxiproxy-{cli,server}
	einstalldocs

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"
}
