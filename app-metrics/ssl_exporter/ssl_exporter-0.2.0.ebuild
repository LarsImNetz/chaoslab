# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GIT_COMMIT="1fab18a" # Change this when you update the ebuild
EGO_PN="github.com/ribbybibby/${PN}"

inherit golang-vcs-snapshot systemd user

DESCRIPTION="Exports Prometheus metrics for SSL certificates"
HOMEPAGE="https://github.com/ribbybibby/ssl_exporter"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="pie test"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/ssl_exporter"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	if use test; then
		# shellcheck disable=SC2086
		if has network-sandbox $FEATURES; then
			ewarn ""
			ewarn "The test phase requires 'network-sandbox' to be disabled in FEATURES"
			ewarn ""
			die "[network-sandbox] is enabled in FEATURES"
		fi
	fi

	enewgroup ssl_exporter
	enewuser ssl_exporter -1 -1 -1 ssl_exporter
}

src_compile() {
	export GOPATH="${G}"
	local PROMU="${EGO_PN}/vendor/github.com/prometheus/common/version"
	# shellcheck disable=SC2207
	local mygoargs=(
		-v -work -x
		$(usex pie '-buildmode=pie' '')
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w
			-X ${PROMU}.Version=${PV}
			-X ${PROMU}.Revision=${GIT_COMMIT}
			-X ${PROMU}.Branch=non-git
			-X ${PROMU}.BuildUser=$(id -un)@$(hostname -f)
			-X ${PROMU}.BuildDate=$(date -u '+%Y%m%d-%I:%M:%S')"
	)
	go build "${mygoargs[@]}" || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin ssl_exporter
	einstalldocs

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"

	diropts -m 0750 -o ssl_exporter -g ssl_exporter
	keepdir /var/log/ssl_exporter
}
