# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/asciimoo/wuzz"
EGO_VENDOR=(
	"golang.org/x/net 1c05540 github.com/golang/net"
	"github.com/jroimartin/gocui eb73455"
	"github.com/mattn/go-runewidth 97311d9"
	"github.com/nsf/termbox-go 4ed959e"
	"github.com/BurntSushi/toml a368813"
	"github.com/mitchellh/go-homedir b8bc1bf"
	"github.com/nwidger/jsoncolor 75a6de4"
	"github.com/fatih/color 67c513e"
	"github.com/tidwall/gjson 4e8f0c7"
	"github.com/x86kernel/htmlcolor cf1d377"
	"github.com/tidwall/match 173748d"
)

inherit golang-vcs-snapshot

DESCRIPTION="Interactive cli tool for HTTP inspection"
HOMEPAGE="https://github.com/asciimoo/wuzz"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DOCS=( CHANGELOG.md README.md )
QA_PRESTRIPPED="usr/bin/wuzz"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
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
	dobin wuzz
	einstalldocs
}
