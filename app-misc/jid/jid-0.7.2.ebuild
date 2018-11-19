# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/simeji/${PN}"
# Snapshot taken on 2018.11.19
EGO_VENDOR=(
	"github.com/bitly/go-simplejson 9db4a59bd4"
	"github.com/fatih/color 3f9d52f717"
	"github.com/mattn/go-runewidth ce7b0b5c7b"
	"github.com/nsf/termbox-go 60ab7e3d12"
	"github.com/nwidger/jsoncolor 75a6de4340"
	"github.com/pkg/errors 059132a15d"
	"github.com/stretchr/testify f35b8ab0b5" # tests
)

inherit golang-vcs-snapshot

DESCRIPTION="JSON incremental digger"
HOMEPAGE="https://github.com/simeji/jid"
SRC_URI="https://${EGO_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="pie"

PATCHES=( "${FILESDIR}/${P}-help_flag.patch" )

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/jid"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "-s -w"
	)
	go build "${mygoargs[@]}" ./cmd/jid || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin jid
	einstalldocs
}
