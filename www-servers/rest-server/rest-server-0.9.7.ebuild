# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/restic/${PN}"

inherit golang-vcs-snapshot systemd user

DESCRIPTION="A high performance HTTP server that implements restic's REST backend API"
HOMEPAGE="https://github.com/restic/rest-server"
SRC_URI="https://${EGO_PN}/releases/download/v${PV}/${P}.tar.gz"
RESTRICT="mirror"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND=">=app-backup/restic-0.7.1"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/rest-server"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_prepare() {
	# Fix systemd unit file
	sed -i \
		-e "s:www-data:rest-server:" \
		-e "s:/usr/local:/usr:" \
		examples/systemd/rest-server.service || die

	default
}

src_compile() {
	export GOPATH="${G}"
	go run build.go || die
}

src_install() {
	dobin rest-server
	einstalldocs

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	systemd_dounit "examples/systemd/${PN}.service"
}

pkg_preinst() {
	enewgroup rest-server
	enewuser rest-server -1 -1 -1 rest-server
}
