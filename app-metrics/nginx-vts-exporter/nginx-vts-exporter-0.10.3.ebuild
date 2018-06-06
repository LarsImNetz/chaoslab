# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit golang-vcs-snapshot systemd user

COMMIT_HASH="8aa2881"
EGO_PN="github.com/hnlq715/nginx-vts-exporter"
DESCRIPTION="A server that scrapes Nginx vts stats and exports them for Prometheus"
HOMEPAGE="https://github.com/hnlq715/nginx-vts-exporter"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror strip"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DOCS=( README.md )

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup nginx_vts_exporter
	enewuser nginx_vts_exporter -1 -1 -1 nginx_vts_exporter
}

src_compile() {
	export GOPATH="${G}"
	local PROMU="vendor/github.com/prometheus/common"
	local GOLDFLAGS="-s -w
		-X ${EGO_PN}/${PROMU}/version.Version=${PV}
		-X ${EGO_PN}/${PROMU}/version.Revision=${COMMIT_HASH}
		-X ${EGO_PN}/${PROMU}/version.BuildUser=$(id -un)@$(hostname -f)
		-X ${EGO_PN}/${PROMU}/version.Branch=non-git
		-X ${EGO_PN}/${PROMU}/version.BuildDate=$(date -u '+%Y%m%d-%I:%M:%S')"

	go build -v -ldflags \
		"${GOLDFLAGS}" || die
}

src_install() {
	dobin nginx-vts-exporter
	einstalldocs

	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	newconfd "${FILESDIR}"/${PN}.confd ${PN}
	systemd_dounit "${FILESDIR}"/${PN}.service

	diropts -o nginx_vts_exporter -g nginx_vts_exporter -m 0750
	keepdir /var/log/nginx_vts_exporter
}
