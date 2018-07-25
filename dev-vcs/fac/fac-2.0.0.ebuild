# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/mkchoi212/${PN}"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
EGO_VENDOR=(
	"github.com/alecthomas/chroma 3020e2e"
	"github.com/danwakefield/fnmatch cbb64ac"
	"github.com/dlclark/regexp2 487489b"
	"github.com/jroimartin/gocui c055c87"
	"github.com/mattn/go-runewidth 9e777a8"
	"github.com/nsf/termbox-go e2050e4"
	"gopkg.in/yaml.v2 5420a8b github.com/go-yaml/yaml"
)

inherit golang-vcs-snapshot

DESCRIPTION="Easy-to-use CUI for fixing git conflicts"
HOMEPAGE="https://github.com/mkchoi212/fac"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="pie"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/fac"

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
	go build "${mygoargs[@]}" || die
}


src_test() {
	# shellcheck disable=SC2046
	go test -race $(go list ./... | grep -v 'testhelper\|fac$') || die
}

src_install() {
	dobin fac
	einstalldocs
	
	doman assets/doc/fac.1
}
