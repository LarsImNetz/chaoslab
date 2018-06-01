# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit golang-vcs-snapshot systemd user

EGO_PN="github.com/fabiolb/fabio"
DESCRIPTION="A load balancing and TCP router for deploying applications managed by consul"
HOMEPAGE="https://fabiolb.net"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror strip test"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="caps"

RDEPEND="caps? ( sys-libs/libcap )"

DOCS=( {{CHANGELOG,README}.md,NOTICES.txt} )

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup fabio
	enewuser fabio -1 -1 /var/lib/fabio fabio
}

src_compile() {
	export GOPATH="${G}"
	local GOLDFLAGS="-s -w \
		-X main.version=${PV}"

	go build -v -ldflags \
		"${GOLDFLAGS}" || die
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
	dodir /var/log/fabio
}

pkg_postinst() {
	if use caps; then
		# Fabio currently does not support dropping privileges so we
		# change attributes with setcap to allow access to priv ports
		setcap "cap_net_bind_service=+ep" "${EROOT%/}"/usr/bin/fabio || die
	fi
}
