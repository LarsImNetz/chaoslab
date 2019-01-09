# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/rgburke/${PN}"
EGO_VENDOR=(
	# Snapshot taken on 2019.01.09
	"github.com/google/go-querystring 44c6ddd0a234" # tests
	"github.com/google/go-github v21.0.0" # tests
	"golang.org/x/oauth2 d668ce993890 github.com/golang/oauth2" # tests
	"golang.org/x/net 1e06a53dbb7e github.com/golang/net" # tests
)

inherit golang-vcs-snapshot-r1

DESCRIPTION="A terminal based interface for viewing Git repositories"
HOMEPAGE="https://github.com/rgburke/grv"
ARCHIVE_URI="https://${EGO_PN}/releases/download/v${PV}/${P}-src.tar.gz -> ${P}.tar.gz"
SRC_URI="${ARCHIVE_URI} ${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86" # Untested: arm arm64 x86
IUSE="debug pie"

RDEPEND="
	>=dev-libs/libgit2-0.27
	sys-libs/ncurses:0
	sys-libs/readline:0
	net-misc/curl
"
DEPEND="${RDEPEND}"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}:${S}/cmd/grv"
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_CXXFLAGS="${CXXFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"
	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "'main.version=v${PV}'"
		-X "'main.buildDateTime=$(date -u '+%Y-%m-%d %H:%M:%S %Z')'"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie exe)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)
	go build "${mygoargs[@]}" ./cmd/grv || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin grv
	use debug && dostrip -x /usr/bin/grv
	einstalldocs
}
