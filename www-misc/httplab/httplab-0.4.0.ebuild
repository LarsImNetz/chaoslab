# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/gchaincl/${PN}"

inherit golang-vcs-snapshot

DESCRIPTION="An interactive web server that let you inspect HTTP requests and forge responses"
HOMEPAGE="https://github.com/gchaincl/httplab"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="pie"

DOCS=( CHANGELOG.md README.md )
QA_PRESTRIPPED="usr/bin/httplab"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w"
	)
	go build "${mygoargs[@]}" ./cmd/httplab || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin httplab
	einstalldocs
}
