# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GIT_COMMIT="4a22506" # Change this when you update the ebuild
EGO_PN="github.com/prometheus/${PN}"

inherit golang-vcs-snapshot systemd user

DESCRIPTION="Prometheus exporter for blackbox probing via HTTP, HTTPS, DNS, TCP and ICMP"
HOMEPAGE="https://prometheus.io"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="pie"

DOCS=( NOTICE CONFIGURATION.md README.md )
QA_PRESTRIPPED="usr/bin/blackbox_exporter"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup blackbox_exporter
	enewuser blackbox_exporter -1 -1 -1 blackbox_exporter
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
	dobin blackbox_exporter
	einstalldocs

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"

	insinto /etc/blackbox_exporter
	newins blackbox.yml blackbox.yml.example

	diropts -o blackbox_exporter -g blackbox_exporter -m 0750
	keepdir /var/log/blackbox_exporter
}
