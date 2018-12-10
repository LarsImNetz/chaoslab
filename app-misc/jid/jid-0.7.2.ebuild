# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/simeji/${PN}"
EGO_VENDOR=(
	# Snapshot taken on 2018.12.10
	"github.com/bitly/go-simplejson 9db4a59bd4d8"
	"github.com/fatih/color 3f9d52f7176a"
	"github.com/mattn/go-runewidth 3ee7d812e62a"
	"github.com/nsf/termbox-go 60ab7e3d12ed"
	"github.com/nwidger/jsoncolor 75a6de4340"
	"github.com/pkg/errors 059132a15dd0"
	"github.com/stretchr/testify v1.2.2" # tests
)

inherit golang-vcs-snapshot-r1

DESCRIPTION="JSON incremental digger"
HOMEPAGE="https://github.com/simeji/jid"
ARCHIVE_URI="https://${EGO_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="${ARCHIVE_URI} ${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86" # Untested: arm arm64 x86
IUSE="debug pie"

PATCHES=( "${FILESDIR}/${P}-help_flag.patch" )

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
	go build "${mygoargs[@]}" ./cmd/jid || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin jid
	use debug && dostrip -x /usr/bin/jid
	einstalldocs
}
