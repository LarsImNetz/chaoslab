# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GIT_COMMIT="e459171"
EGO_PN="github.com/prometheus/${PN}"

inherit golang-vcs-snapshot systemd user

DESCRIPTION="An exporter that exposes information gathered from SNMP for Prometheus"
HOMEPAGE="https://prometheus.io"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="pie test"

DEPEND="test? ( net-analyzer/net-snmp )"

DOCS=( NOTICE README.md )
QA_PRESTRIPPED="usr/bin/snmp_exporter"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	# shellcheck disable=SC2086
	if use test; then
		has network-sandbox $FEATURES && \
			die "The test phase requires 'network-sandbox' to be disabled in FEATURES"
	fi

	enewgroup snmp_exporter
	enewuser snmp_exporter -1 -1 -1 snmp_exporter
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
	dobin snmp_exporter
	einstalldocs

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"

	insinto /etc/snmp_exporter
	newins snmp.yml snmp.yml.example

	diropts -o snmp_exporter -g snmp_exporter -m 0750
	keepdir /var/log/snmp_exporter
}

pkg_postinst() {
	if [ ! -e "${EROOT%/}"/etc/snmp_exporter/snmp.yml ]; then
		elog "No snmp.yml found, copying the example over"
		cp "${EROOT%/}"/etc/snmp_exporter/snmp.yml{.example,} || die
	else
		elog "snmp.yml found, please check example file for possible changes"
	fi
}
