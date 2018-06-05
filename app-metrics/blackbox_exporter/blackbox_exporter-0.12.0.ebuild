# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit golang-vcs-snapshot systemd user

GIT_COMMIT="4a22506"
EGO_PN="github.com/prometheus/${PN/prometheus-}"
DESCRIPTION="Allows blackbox probing of endpoints over HTTP, HTTPS, DNS, TCP and ICMP"
HOMEPAGE="https://prometheus.io"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror strip"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

DOCS=( NOTICE {CONFIGURATION,README}.md )

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup blackbox_exporter
	enewuser blackbox_exporter -1 -1 -1 blackbox_exporter
}

src_compile() {
	export GOPATH="${G}"
	local GOLDFLAGS="-s -w
		-X ${EGO_PN}/vendor/${EGO_PN%/*}/common/version.Version=${PV}
		-X ${EGO_PN}/vendor/${EGO_PN%/*}/common/version.Revision=${GIT_COMMIT}
		-X ${EGO_PN}/vendor/${EGO_PN%/*}/common/version.BuildUser=$(id -un)@$(hostname -f)
		-X ${EGO_PN}/vendor/${EGO_PN%/*}/common/version.Branch=non-git
		-X ${EGO_PN}/vendor/${EGO_PN%/*}/common/version.BuildDate=$(date -u '+%Y%m%d-%I:%M:%S')"

	go build -v -ldflags \
		"${GOLDFLAGS}" || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin blackbox_exporter
	einstalldocs

	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	newconfd "${FILESDIR}"/${PN}.confd ${PN}
	systemd_dounit "${FILESDIR}"/${PN}.service

	insinto /etc/blackbox_exporter
	newins blackbox.yml blackbox.yml.example

	diropts -o blackbox_exporter -g blackbox_exporter -m 0750
	keepdir /var/log/blackbox_exporter
}
