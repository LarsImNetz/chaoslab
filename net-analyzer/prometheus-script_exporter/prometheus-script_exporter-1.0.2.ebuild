# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# Note: Keep EGO_VENDOR in sync with vendor/vendor.json
EGO_VENDOR=(
	"github.com/Sirupsen/logrus 881bee4"
	"github.com/beorn7/perks 4c0e845"
	"github.com/golang/protobuf 8ee7999"
	"github.com/matttproud/golang_protobuf_extensions c12348c"
	"github.com/prometheus/client_golang 575f371"
	"github.com/prometheus/client_model fa8ad6f"
	"github.com/prometheus/common 6d76b79"
	"github.com/prometheus/procfs fcdb11c"
	"gopkg.in/yaml.v2 a5b47d3 github.com/go-yaml/yaml"
)

inherit golang-vcs-snapshot systemd user

GIT_COMMIT="3ee25c0"
EGO_PN="github.com/adhocteam/${PN/prometheus-}"
DESCRIPTION="A Prometheus exporter for shell script exit status and duration"
HOMEPAGE="https://github.com/adhocteam/script_exporter"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror strip"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DOCS=( README.md )

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup script_exporter
	enewuser script_exporter -1 -1 -1 script_exporter
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
	go test -v ./... || die
}

src_install() {
	dobin script_exporter
	einstalldocs

	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	newconfd "${FILESDIR}"/${PN}.confd ${PN}
	systemd_dounit "${FILESDIR}"/${PN}.service

	insinto /etc/script_exporter
	doins script-exporter.yml

	diropts -o script_exporter -g script_exporter -m 0750
	keepdir /var/log/script_exporter
}
