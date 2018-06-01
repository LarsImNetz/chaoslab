# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_VENDOR=(
	"golang.org/x/net f5079bd github.com/golang/net"
	"github.com/jroimartin/gocui 612b0b2"
	"github.com/mattn/go-runewidth 97311d9"
	"github.com/nsf/termbox-go 4ed959e"
	"github.com/BurntSushi/toml a368813"
	"github.com/mitchellh/go-homedir b8bc1bf"
	"github.com/nwidger/jsoncolor 75a6de4"
	"github.com/fatih/color 62e9147"
)

inherit golang-vcs-snapshot

EGO_PN="github.com/asciimoo/wuzz"
DESCRIPTION="Interactive cli tool for HTTP inspection"
HOMEPAGE="https://github.com/asciimoo/wuzz"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RESTRICT="mirror strip"

DOCS=( {CHANGELOG,README}.md )

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
	dobin wuzz
	einstalldocs
}
