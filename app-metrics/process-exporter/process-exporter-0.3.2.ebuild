# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/ncabatoff/${PN}"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
EGO_VENDOR=(
	"github.com/beorn7/perks 3a771d9"
	"github.com/golang/protobuf b4deda0"
	"github.com/google/go-cmp 3af367b"
	"github.com/kr/pretty 73f6ac0"
	"github.com/kr/text e2ffdb"
	"github.com/matttproud/golang_protobuf_extensions c12348c"
	"github.com/ncabatoff/fakescraper 1593842"
	"github.com/ncabatoff/go-seq b08ef85"
	"github.com/ncabatoff/procfs d7a0c83"
	"github.com/prometheus/client_golang c5b7fcc"
	"github.com/prometheus/client_model 5c3871d"
	"github.com/prometheus/common c7de230"
	"github.com/prometheus/procfs 05ee40e"
	"gopkg.in/check.v1 788fd78 github.com/go-check/check"
	"gopkg.in/yaml.v2 5420a8b github.com/go-yaml/yaml"
)

inherit golang-vcs-snapshot systemd user

DESCRIPTION="A Prometheus exporter that mines /proc to report on selected processes"
HOMEPAGE="https://github.com/ncabatoff/process-exporter"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="pie"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/process-exporter"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup process-exporter
	enewuser process-exporter -1 -1 -1 process-exporter
}

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w"
	)
	go build "${mygoargs[@]}" ./cmd/process-exporter || die
}

src_install() {
	dobin process-exporter
	einstalldocs

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	systemd_newunit "${FILESDIR}/${PN}.service-r1" "${PN}.service"

	diropts -o process-exporter -g process-exporter -m 0750
	keepdir /var/log/process-exporter
}
