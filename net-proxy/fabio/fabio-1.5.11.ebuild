# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/fabiolb/${PN}"

inherit fcaps golang-vcs-snapshot-r1 systemd user

DESCRIPTION="A load balancing and TCP router for deploying applications managed by consul"
HOMEPAGE="https://fabiolb.net"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug pie test"

DEPEND="
	test? (
		app-admin/consul
		app-admin/vault
	)
"

FILECAPS=( cap_net_bind_service+ep usr/bin/fabio )

DOCS=( CHANGELOG.md README.md NOTICES.txt )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup fabio
	enewuser fabio -1 -1 /var/lib/fabio fabio
}

src_compile() {
	export GOPATH="${G}"

	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "main.version=${PV}"
	)

	local mygoargs=(
		-v -work -x
		-buildmode "$(usex pie pie exe)"
		-asmflags "all=-trimpath=${S}"
		-gcflags "all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)

	go build "${mygoargs[@]}" || die
}

src_test() {
	go test -v -timeout 15s ./... || die
}

src_install() {
	dobin fabio
	use debug && dostrip -x /usr/bin/fabio
	einstalldocs

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"

	insinto /etc/logrotate.d
	newins "${FILESDIR}/${PN}.logrotate" "${PN}"

	diropts -o fabio -g fabio -m 0750
	keepdir /var/log/fabio
}
