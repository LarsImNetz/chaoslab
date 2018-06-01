# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit golang-vcs-snapshot systemd user

EGO_PN="github.com/lovoo/${PN/prometheus-}"
DESCRIPTION="A Prometheus metrics exporter for NSQ"
HOMEPAGE="https://github.com/lovoo/nsq_exporter"
SRC_URI="https://${EGO_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror strip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

DOCS=( README.md )

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup nsq_exporter
	enewuser nsq_exporter -1 -1 -1 nsq_exporter
}

src_compile() {
	export GOPATH="${G}"
	go build -v -ldflags "-s -w" || die
}

src_install() {
	dobin nsq_exporter
	einstalldocs

	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	newconfd "${FILESDIR}"/${PN}.confd ${PN}
	systemd_dounit "${FILESDIR}"/${PN}.service

	diropts -o nsq_exporter -g nsq_exporter -m 0750
	keepdir /var/log/nsq_exporter
}
