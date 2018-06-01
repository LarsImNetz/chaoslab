# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_VENDOR=(
	"github.com/fatih/color 62e9147"
	"github.com/heppu/rawterm f84711c"
	"github.com/k0kubun/go-ansi c49b543"
	"github.com/mitchellh/go-ps 4fdf99a"
)

inherit golang-vcs-snapshot

EGO_PN="github.com/heppu/${PN}"
DESCRIPTION="An interactive process killer"
HOMEPAGE="https://github.com/heppu/gkill"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RESTRICT="mirror strip"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	go build -v -ldflags "-s -w" || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin gkill
	dodoc README.md
}
