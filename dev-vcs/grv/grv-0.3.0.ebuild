# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/rgburke/${PN}"
# Snapshot taken on 2018.11.17
EGO_VENDOR=(
	"github.com/google/go-querystring 44c6ddd0a2" # tests
	"github.com/google/go-github f55b50f381" # tests
	"golang.org/x/oauth2 f42d051822 github.com/golang/oauth2" # tests
	"golang.org/x/net adae6a3d11 github.com/golang/net" # tests
)

inherit golang-vcs-snapshot

DESCRIPTION="A terminal based interface for viewing Git repositories"
HOMEPAGE="https://github.com/rgburke/grv"
SRC_URI="https://${EGO_PN}/releases/download/v${PV}/${P}-src.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="pie"

RDEPEND="
	>=dev-libs/libgit2-0.27
	sys-libs/ncurses:0
	sys-libs/readline:0
	net-misc/curl
"
DEPEND="${RDEPEND}"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/grv"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}:${S}/cmd/grv"
	local myldflags=( -s -w
		-X "'main.version=v${PV}'"
		-X "'main.buildDateTime=$(date -u '+%Y-%m-%d %H:%M:%S %Z')'"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
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
	einstalldocs
}
