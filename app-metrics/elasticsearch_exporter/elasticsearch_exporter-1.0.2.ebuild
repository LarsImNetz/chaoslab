# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit golang-vcs-snapshot systemd user

GIT_COMMIT="92dcbf3"
EGO_PN="github.com/justwatchcom/${PN/prometheus-}"
DESCRIPTION="Elasticsearch stats exporter for Prometheus"
HOMEPAGE="https://github.com/justwatchcom/elasticsearch_exporter"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror strip"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="examples"

DOCS=( {CHANGELOG,README}.md )

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup elasticsearch_exporter
	enewuser elasticsearch_exporter -1 -1 -1 elasticsearch_exporter
}

src_compile() {
	export GOPATH="${G}"
	local PROMU="vendor/github.com/prometheus/common"
	local GOLDFLAGS="-s -w \
		-X ${EGO_PN}/${PROMU}/version.Version=${PV} \
		-X ${EGO_PN}/${PROMU}/version.Revision=${GIT_COMMIT} \
		-X ${EGO_PN}/${PROMU}/version.BuildUser=$(id -un)@$(hostname -f) \
		-X ${EGO_PN}/${PROMU}/version.Branch=non-git \
		-X ${EGO_PN}/${PROMU}/version.BuildDate=$(date -u '+%Y%m%d-%I:%M:%S')"

	go build -v -ldflags \
		"${GOLDFLAGS}" || die
}

src_test() {
	go test -v -short ./... || die
}

src_install() {
	dobin elasticsearch_exporter
	einstalldocs

	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	newconfd "${FILESDIR}"/${PN}.confd ${PN}
	systemd_dounit "${FILESDIR}"/${PN}.service

	if use examples; then
		docinto examples
		dodoc -r example/*
		docompress -x /usr/share/doc/${PF}/examples
	fi

	diropts -o elasticsearch_exporter -g elasticsearch_exporter -m 0750
	keepdir /var/log/elasticsearch_exporter
}
