# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GIT_COMMIT="7c2b385" # Change this when you update the ebuild
EGO_PN="github.com/jonnenauha/prometheus_${PN}"
# Snapshot taken on 2018.07.11
EGO_VENDOR=(
	"github.com/beorn7/perks 3a771d9"
	"github.com/golang/protobuf 0cb4f73"
	"github.com/matttproud/golang_protobuf_extensions c12348c"
	"github.com/prometheus/client_golang ee1c9d7"
	"github.com/prometheus/client_model 99fa1f4"
	"github.com/prometheus/common 7600349"
	"github.com/prometheus/procfs ae68e2d"
)

inherit golang-vcs-snapshot systemd user

DESCRIPTION="Varnish exporter for Prometheus"
HOMEPAGE="https://github.com/jonnenauha/prometheus_varnish_exporter"
SRC_URI="https://${EGO_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="pie"

DOCS=( CHANGELOG.md README.md )
QA_PRESTRIPPED="usr/bin/prometheus_varnish_exporter"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup varnish_exporter
	enewuser varnish_exporter -1 -1 -1 varnish_exporter
}

src_compile() {
	export GOPATH="${G}"
	local myldflags=( -s -w
		-X "main.Version=${PV}"
		-X "main.VersionHash=${GIT_COMMIT}"
		-X "'main.VersionDate=$(date -u '+%d.%m.%Y %H:%M:%S')'"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)
	go build "${mygoargs[@]}" || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin prometheus_varnish_exporter
	einstalldocs

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"

	diropts -o varnish_exporter -g varnish_exporter -m 0750
	keepdir /var/log/varnish_exporter
}
