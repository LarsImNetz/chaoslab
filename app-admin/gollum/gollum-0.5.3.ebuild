# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/trivago/${PN}"

inherit golang-vcs-snapshot systemd user

DESCRIPTION="An n:m message multiplexer written in Go"
HOMEPAGE="https://github.com/trivago/gollum"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="examples pie test"

DOCS=( {CHANGELOG,README}.md )
QA_PRESTRIPPED="usr/bin/gollum"

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

	enewgroup gollum
	enewuser gollum -1 -1 -1 gollum
}

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w -X ${EGO_PN}/core.versionString=${PV}"
	)
	go build "${mygoargs[@]}" || die
}

src_test(){
	# Run all unit tests
	go test -v -cover -timeout 10s \
		-race -tags unit ./... || die

	# Run all integration tests
	go test -ldflags "-X ${EGO_PN}/core.versionString=${PV}" \
		-v -race -tags integration ./testing/integration || die
}

src_install() {
	dobin gollum
	einstalldocs

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"

	dodir /etc/gollum

	if use examples; then
		docinto examples
		dodoc -r config/*
		docompress -x "/usr/share/doc/${PF}/examples"
	fi

	diropts -o gollum -g gollum -m 0750
	keepdir /var/log/gollum
}
