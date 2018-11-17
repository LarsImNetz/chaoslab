# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GIT_COMMIT="ad6568b" # Change this when you update the ebuild
EGO_PN="github.com/prometheus/${PN}"

inherit golang-vcs-snapshot systemd user

DESCRIPTION="A server that accepts collectd stats for Prometheus consumption"
HOMEPAGE="https://prometheus.io"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="pie"

DOCS=( NOTICE CHANGELOG.md README.md )
QA_PRESTRIPPED="usr/bin/collectd_exporter"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup collectd_exporter
	enewuser collectd_exporter -1 -1 -1 collectd_exporter
}

src_compile() {
	export GOPATH="${G}"
	local PROMU="${EGO_PN}/vendor/${EGO_PN%/*}/common/version"
	local myldflags=( -s -w
		-X "${PROMU}.Version=${PV}"
		-X "${PROMU}.Revision=${GIT_COMMIT}"
		-X "${PROMU}.Branch=non-git"
		-X "${PROMU}.BuildUser=$(id -un)@$(hostname -f)"
		-X "${PROMU}.BuildDate=$(date -u '+%Y%m%d-%I:%M:%S')"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)
	go build "${mygoargs[@]}" || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin collectd_exporter
	einstalldocs

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"

	diropts -o collectd_exporter -g collectd_exporter -m 0750
	keepdir /var/log/collectd_exporter
}
