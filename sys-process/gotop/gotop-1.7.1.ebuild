# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/cjbassi/${PN}"
EGO_VENDOR=(
	# Note: Keep EGO_VENDOR in sync with go.mod
	#"github.com/StackExchange/wmi 5d049714c4a6"
	#"github.com/cjbassi/drawille-go ad535d0f92cd"
	"github.com/cjbassi/termui e8dd23f6146c"
	#"github.com/davecgh/go-spew v1.1.1"
	"github.com/docopt/docopt-go ee0de3bc6815"
	#"github.com/go-ole/go-ole v1.2.1"
	#"github.com/mattn/go-runewidth v0.0.2"
	#"github.com/nsf/termbox-go 3e24a7b6661e"
	#"github.com/pmezard/go-difflib v1.0.0"
	"github.com/shirou/gopsutil v2.18.11"
	#"github.com/shirou/w32 bb4de0191aa4"
	#"github.com/stretchr/testify v1.2.2"
	"golang.org/x/sys 3b87a42e500a github.com/golang/sys"
)

inherit golang-vcs-snapshot-r1

DESCRIPTION="A terminal based graphical activity monitor inspired by gtop and vtop"
HOMEPAGE="https://github.com/cjbassi/gotop"
ARCHIVE_URI="https://${EGO_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="${ARCHIVE_URI} ${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86" # Untested: arm arm64 x86
IUSE="debug pie"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie exe)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "$(usex !debug '-s -w' '')"
	)
	go build "${mygoargs[@]}" || die
}

src_install() {
	dobin gotop
	use debug && dostrip -x /usr/bin/gotop
	einstalldocs
}
