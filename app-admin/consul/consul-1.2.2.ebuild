# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/hashicorp/${PN}"
GIT_COMMIT="e716d1b" # Change this when you update the ebuild

inherit golang-vcs-snapshot systemd user

DESCRIPTION="A tool for service discovery, monitoring and configuration"
HOMEPAGE="https://www.consul.io"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror test"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="pie"

DOCS=( CHANGELOG.md README.md )
QA_PRESTRIPPED="usr/bin/consul"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup consul
	enewuser consul -1 -1 /var/lib/consul consul
}

src_compile() {
	export GOPATH="${G}"
	local myldflags=( -s -w
		-X "${EGO_PN}/version.GitCommit=${GIT_COMMIT}"
		-X "${EGO_PN}/version.GitDescribe=v${PV/_*}"
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

src_install() {
	dobin consul
	einstalldocs

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"

	insinto /etc/consul.d
	doins "${FILESDIR}"/*.example

	insinto /etc/logrotate.d
	newins "${FILESDIR}/${PN}.logrotate" "${PN}"

	diropts -o consul -g consul -m 0750
	keepdir /var/log/consul
}

pkg_postinst() {
	if [[ $(stat -c %a "${EROOT%/}/var/lib/consul") != "750" ]]; then
		einfo "Fixing ${EROOT%/}/var/lib/consul permissions"
		chown consul:consul "${EROOT%/}/var/lib/consul" || die
		chmod 0750 "${EROOT%/}/var/lib/consul" || die
	fi
}
