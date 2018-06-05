# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GIT_COMMIT="a0a3449" # Change this when you update the ebuild
EGO_PN="github.com/prometheus/${PN}"

inherit golang-vcs-snapshot systemd user

DESCRIPTION="Exports metrics from memcached servers for consumption by Prometheus"
HOMEPAGE="https://prometheus.io"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="pie test"

DOCS=( NOTICE README.md )
QA_PRESTRIPPED="usr/bin/memcached_exporter"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	if use test; then
		# shellcheck disable=SC2086
		has network-sandbox $FEATURES && \
			die "The test phase require 'network-sandbox' to be disabled in FEATURES"
	fi

	enewgroup memcached_exporter
	enewuser memcached_exporter -1 -1 -1 memcached_exporter
}

src_compile() {
	export GOPATH="${G}"
	local PROMU="${EGO_PN}/vendor/${EGO_PN%/*}/common/version"
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
	dobin memcached_exporter
	einstalldocs

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"

	diropts -o memcached_exporter -g memcached_exporter -m 0750
	keepdir /var/log/memcached_exporter
}
