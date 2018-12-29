# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/codesenberg/${PN}"

inherit golang-vcs-snapshot-r1

DESCRIPTION="Fast cross-platform HTTP benchmarking tool written in Go"
HOMEPAGE="https://github.com/codesenberg/bombardier"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug pie simplebenchserver"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "main.version=${PV}"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie exe)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)
	go build "${mygoargs[@]}" || die

	if use simplebenchserver; then
		go build -v -ldflags "$(usex !debug '-s -w' '')" \
			./cmd/utils/simplebenchserver || die
	fi
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin bombardier
	use debug && dostrip -x /usr/bin/bombardier
	einstalldocs

	if use simplebenchserver; then
		dobin simplebenchserver
		use debug && dostrip -x /usr/bin/simplebenchserver
	fi
}
