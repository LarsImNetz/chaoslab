# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/fabiolb/fabio"

inherit fcaps golang-vcs-snapshot systemd user

DESCRIPTION="A load balancing and TCP router for deploying applications managed by consul"
HOMEPAGE="https://fabiolb.net"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror test"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="pie"

DOCS=( {CHANGELOG,README}.md NOTICES.txt )
FILECAPS=( cap_net_bind_service+ep usr/bin/fabio )
QA_PRESTRIPPED="usr/bin/fabio"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup fabio
	enewuser fabio -1 -1 /var/lib/fabio fabio
}

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		$(usex pie '-buildmode=pie' '')
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w -X main.version=${PV}"
	)
	go build "${mygoargs[@]}" || die
}

src_install() {
	dobin fabio
	einstalldocs

	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	systemd_dounit "${FILESDIR}"/${PN}.service
	systemd_newtmpfilesd "${FILESDIR}"/${PN}.tmpfilesd ${PN}.conf

	insinto /etc/logrotate.d
	newins "${FILESDIR}"/${PN}.logrotate ${PN}

	diropts -o fabio -g fabio -m 0750
	keepdir /var/log/fabio
}
