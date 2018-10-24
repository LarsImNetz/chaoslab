# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/hashicorp/${PN}"
GIT_COMMIT="612120e76d" # Change this when you update the ebuild

inherit fcaps golang-vcs-snapshot systemd user

DESCRIPTION="A tool for managing secrets"
HOMEPAGE="https://vaultproject.io"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror test"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="pie"

DOCS=( CHANGELOG.md README.md )
FILECAPS=( -m 755 'cap_ipc_lock=+ep' usr/bin/vault )
QA_PRESTRIPPED="usr/bin/vault"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup vault
	enewuser vault -1 -1 -1 vault
}

src_compile() {
	export GOPATH="${G}"
	local myldflags=( -s -w
		-X "${EGO_PN}/version.GitCommit=${GIT_COMMIT}"
		-X "${EGO_PN}/version.Version=${PV}"
		-X "${EGO_PN}/version.VersionPrerelease="
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "${myldflags[*]}"
		-tags vault
		-o ./bin/vault
	)
	go build "${mygoargs[@]}" || die
}

src_install() {
	dobin bin/vault
	einstalldocs

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"

	insinto /etc/vault.d
	doins "${FILESDIR}"/*.example

	insinto /etc/logrotate.d
	newins "${FILESDIR}/${PN}.logrotate" "${PN}"

	diropts  -o vault -g vault -m 0750
	keepdir /var/log/vault
}
