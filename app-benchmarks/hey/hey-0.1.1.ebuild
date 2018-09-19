# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/rakyll/hey"
# Snapshot taken on 2018.09.19
EGO_VENDOR=(
	"golang.org/x/net 26e67e7 github.com/golang/net"
	"golang.org/x/text 905a571 github.com/golang/text"
)

inherit golang-vcs-snapshot

DESCRIPTION="HTTP load generator, ApacheBench (ab) replacement"
HOMEPAGE="https://github.com/rakyll/hey"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/hey"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w"
	)
	go build "${mygoargs[@]}" || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin hey
	einstalldocs
}
