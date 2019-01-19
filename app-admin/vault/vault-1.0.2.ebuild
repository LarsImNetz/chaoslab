# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Change this when you update the ebuild
GIT_COMMIT="37a1dc9c477c1c68c022d2084550f25bf20cac33"
EGO_PN="github.com/hashicorp/${PN}"

inherit fcaps golang-vcs-snapshot-r1 systemd user

DESCRIPTION="A tool for managing secrets"
HOMEPAGE="https://vaultproject.io"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror test" # Test requires docker

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug pie"

FILECAPS=( -m 755 'cap_ipc_lock=+ep' usr/bin/vault )

DOCS=( CHANGELOG.md README.md )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup vault
	enewuser vault -1 -1 -1 vault
}

src_compile() {
	export GOPATH="${G}"
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"

	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "${EGO_PN}/version.GitCommit=${GIT_COMMIT}"
		-X "${EGO_PN}/version.Version=${PV}"
		-X "${EGO_PN}/version.VersionPrerelease="
	)

	local mygoargs=(
		-v -work -x
		-buildmode "$(usex pie pie exe)"
		-asmflags "all=-trimpath=${S}"
		-gcflags "all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
		-tags vault
		-o ./bin/vault
	)

	go build "${mygoargs[@]}" || die
}

src_install() {
	dobin bin/vault
	use debug && dostrip -x /usr/bin/vault
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
