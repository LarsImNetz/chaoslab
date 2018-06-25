# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/knqyf263/${PN}"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
# Deps that are not needed:
# github.com/golang/protobuf
# github.com/inconshreveable/mousetrap
# github.com/mattn/go-colorable
# github.com/mattn/go-isatty
# google.golang.org/appengine
EGO_VENDOR=(
	"github.com/BurntSushi/toml b26d9c3"
	"github.com/briandowns/spinner 48dbb65"
	"github.com/chzyer/readline 2972be2"
	"github.com/fatih/color 5b77d2a"
	"github.com/google/go-github e48060a"
	"github.com/google/go-querystring 53e6ce1"
	"github.com/jroimartin/gocui c055c87"
	"github.com/mattn/go-runewidth 9e777a8"
	"github.com/nsf/termbox-go 21a4d43"
	"github.com/pkg/errors 645ef00"
	"github.com/spf13/cobra ef82de7"
	"github.com/spf13/pflag 583c0c0"
	"github.com/xanzy/go-gitlab 26ea551"
	"golang.org/x/crypto 8ac0e0d github.com/golang/crypto"
	"golang.org/x/net 1e49130 github.com/golang/net"
	"golang.org/x/oauth2 1e0a3fa github.com/golang/oauth2"
	"golang.org/x/sys 9527bec github.com/golang/sys"
)

inherit golang-vcs-snapshot

DESCRIPTION="Simple command-line snippet manager, written in Go"
HOMEPAGE="https://github.com/knqyf263/pet"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="pie zsh-completion"

RDEPEND="
	|| ( app-shells/fzf app-shells/peco )
	zsh-completion? ( app-shells/zsh )
"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/pet"

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
	go test -v ./... || die
}

src_install() {
	dobin pet
	einstalldocs

	if use zsh-completion; then
		insinto /usr/share/zsh/site-functions
		doins misc/completions/zsh/_pet
	fi
}
