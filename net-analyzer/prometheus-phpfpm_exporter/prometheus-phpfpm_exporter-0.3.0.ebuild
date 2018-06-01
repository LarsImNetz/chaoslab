# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit golang-vcs-snapshot systemd user

GIT_COMMIT="2cd2fd5"
EGO_PN="github.com/Lusitaniae/${PN/prometheus-}"
DESCRIPTION="A Prometheus exporter for PHP-FPM"
HOMEPAGE="https://github.com/Lusitaniae/phpfpm_exporter"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror strip"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

DOCS=( README.md )

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup phpfpm_exporter
	enewuser phpfpm_exporter -1 -1 -1 phpfpm_exporter
}

src_compile() {
	export GOPATH="${G}"
	local PROMU="vendor/github.com/prometheus/common"
	local GOLDFLAGS="-s -w
		-X ${EGO_PN}/${PROMU}/version.Version=${PV}
		-X ${EGO_PN}/${PROMU}/version.Revision=${GIT_COMMIT}
		-X ${EGO_PN}/${PROMU}/version.Branch=non-git
		-X ${EGO_PN}/${PROMU}/version.BuildUser=$(id -un)@$(hostname -f)
		-X ${EGO_PN}/${PROMU}/version.BuildDate=$(date -u '+%Y%m%d-%I:%M:%S')"

	go build -v -ldflags \
		"${GOLDFLAGS}" || die
}

src_test() {
	go test -v -short ./... || die
}

src_install() {
	dobin phpfpm_exporter
	einstalldocs

	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	newconfd "${FILESDIR}"/${PN}.confd ${PN}
	systemd_dounit "${FILESDIR}"/${PN}.service

	diropts -o phpfpm_exporter -g phpfpm_exporter -m 0750
	keepdir /var/log/phpfpm_exporter
}
