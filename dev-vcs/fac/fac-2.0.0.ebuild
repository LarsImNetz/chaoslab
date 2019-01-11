# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/mkchoi212/${PN}"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
EGO_VENDOR=(
	"github.com/alecthomas/chroma v0.4.0"
	"github.com/danwakefield/fnmatch cbb64ac3d964"
	"github.com/dlclark/regexp2 v1.1.6"
	"github.com/jroimartin/gocui c055c87ae801"
	"github.com/mattn/go-runewidth v0.0.2"
	"github.com/nsf/termbox-go e2050e41c884"
	"gopkg.in/yaml.v2 v2.2.1 github.com/go-yaml/yaml"
)

inherit flag-o-matic golang-vcs-snapshot-r1

DESCRIPTION="Easy-to-use CUI for fixing git conflicts"
HOMEPAGE="https://github.com/mkchoi212/fac"
ARCHIVE_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="${ARCHIVE_URI} ${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
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
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie exe)"
		-asmflags "all=-trimpath=${S}"
		-gcflags "all=-trimpath=${S}"
		-ldflags "$(usex !debug '-s -w' '')"
	)
	go build "${mygoargs[@]}" || die
}

src_test() {
	# shellcheck disable=SC2046
	go test -race $(go list ./... | grep -v 'testhelper\|fac$') || die
}

src_install() {
	dobin fac
	use debug && dostrip -x /usr/bin/fac
	einstalldocs
	doman assets/doc/fac.1
}
