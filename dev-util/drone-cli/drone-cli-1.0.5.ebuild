# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/drone/${PN}"

inherit flag-o-matic golang-vcs-snapshot-r1

DESCRIPTION="Command line client for the Drone continuous integration server"
HOMEPAGE="https://drone.io"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug pie static"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_prepare() {
	if use static; then
		use pie || export CGO_ENABLED=0
		use pie && append-ldflags -static
	fi
	default
}

src_compile() {
	export GOPATH="${G}"
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"
	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "main.version=${PV}"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie exe)"
		-asmflags "all=-trimpath=${S}"
		-gcflags "all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
		-o ./bin/drone
	)
	go build "${mygoargs[@]}" ./drone || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin bin/drone
	use debug && dostrip -x /usr/bin/drone
	einstalldocs
}
