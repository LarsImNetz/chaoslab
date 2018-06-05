# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_VENDOR=(
	"github.com/beorn7/perks 3a771d9"
	"github.com/golang/protobuf b4deda0"
	"github.com/matttproud/golang_protobuf_extensions c12348c"
	"github.com/prometheus/client_golang 82f5ff1"
	"github.com/prometheus/client_model 99fa1f4"
	"github.com/prometheus/common d811d2e"
	"github.com/prometheus/procfs 8b1c2da"
	"github.com/alecthomas/template a0175ee"
	"github.com/alecthomas/units 2efee85"
	"gopkg.in/alecthomas/kingpin.v2 947dcec github.com/alecthomas/kingpin"
)

inherit golang-vcs-snapshot systemd user

EGO_PN="github.com/kumina/${PN/prometheus-}"
DESCRIPTION="A Prometheus metrics exporter for the Dovecot mail server"
HOMEPAGE="https://github.com/kumina/dovecot_exporter"
SRC_URI="https://${EGO_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror strip"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

DOCS=( {CHANGELOG,README}.md )

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup dovecot_exporter
	enewuser dovecot_exporter -1 -1 -1 dovecot_exporter
}

src_compile() {
	export GOPATH="${G}"
	go build -v -ldflags "-s -w" || die
}

src_install() {
	dobin dovecot_exporter
	einstalldocs

	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	newconfd "${FILESDIR}"/${PN}.confd ${PN}
	systemd_dounit "${FILESDIR}"/${PN}.service

	diropts -o dovecot_exporter -g dovecot_exporter -m 0750
	keepdir /var/log/dovecot_exporter
}
