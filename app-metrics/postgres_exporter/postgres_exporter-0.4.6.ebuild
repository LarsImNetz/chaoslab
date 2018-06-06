# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit golang-vcs-snapshot systemd user

EGO_PN="github.com/wrouesnel/${PN/prometheus-}"
DESCRIPTION="Prometheus exporter for PostgreSQL server metrics"
HOMEPAGE="https://github.com/wrouesnel/postgres_exporter"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror strip"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

DOCS=( README.md )

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup postgres_exporter
	enewuser postgres_exporter -1 -1 -1 postgres_exporter
}

src_compile() {
	export GOPATH="${G}"
	local GOLDFLAGS="-s -w -X main.Version=${PV}"

	go build -v -ldflags \
		"${GOLDFLAGS}" ./cmd/postgres_exporter || die
}

src_install() {
	dobin postgres_exporter
	einstalldocs

	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	newconfd "${FILESDIR}"/${PN}.confd ${PN}
	systemd_dounit "${FILESDIR}"/${PN}.service

	diropts -o postgres_exporter -g postgres_exporter -m 0750
	keepdir /var/log/postgres_exporter
}
