# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/knqyf263/${PN}"
# Note: Keep EGO_VENDOR in sync with go.mod
EGO_VENDOR=(
	"github.com/BurntSushi/toml v0.3.0"
	"github.com/briandowns/spinner 48dbb65d7bd5"
	"github.com/chzyer/readline 2972be24d48e"
	"github.com/fatih/color v1.7.0"
	#"github.com/golang/protobuf v1.1.0"
	"github.com/google/go-github v15.0.0"
	"github.com/google/go-querystring 53e6ce116135"
	#"github.com/inconshreveable/mousetrap v1.0.0"
	"github.com/jroimartin/gocui v0.4.0"
	#"github.com/mattn/go-colorable v0.0.9"
	#"github.com/mattn/go-isatty v0.0.3"
	"github.com/mattn/go-runewidth v0.0.2"
	"github.com/nsf/termbox-go 21a4d435a862"
	"github.com/pkg/errors v0.8.0"
	"github.com/spf13/cobra v0.0.3"
	"github.com/spf13/pflag v1.0.1"
	"github.com/xanzy/go-gitlab v0.10.5"
	"golang.org/x/crypto 8ac0e0d97ce4 github.com/golang/crypto"
	"golang.org/x/net 1e491301e022 github.com/golang/net"
	"golang.org/x/oauth2 1e0a3fa8ba9a github.com/golang/oauth2"
	"golang.org/x/sys 9527bec2660b github.com/golang/sys"
	#"google.golang.org/appengine v1.0.0 github.com/golang/appengine"
)

inherit golang-vcs-snapshot-r1

DESCRIPTION="Simple command-line snippet manager, written in Go"
HOMEPAGE="https://github.com/knqyf263/pet"
ARCHIVE_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="${ARCHIVE_URI} ${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86" # Untested: arm arm64 x86
IUSE="debug pie static"

RDEPEND="|| ( app-shells/fzf app-shells/peco )"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"
	(use static && use pie) && CGO_LDFLAGS+=" -static"

	local mygoargs=(
		-v -work -x
		-buildmode "$(usex pie pie exe)"
		-asmflags "all=-trimpath=${S}"
		-gcflags "all=-trimpath=${S}"
		-ldflags "$(usex !debug '-s -w' '')"
		-tags "$(usex static 'netgo' '')"
		-installsuffix "$(usex static 'netgo' '')"
	)

	go build "${mygoargs[@]}" || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin pet
	use debug && dostrip -x /usr/bin/pet
	einstalldocs

	insinto /usr/share/zsh/site-functions
	doins misc/completions/zsh/_pet
}
