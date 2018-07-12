# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# Change this when you update the ebuild:
GIT_COMMIT="5cac42bcf3e7094dbcaffefd7b5a62d8453faa9f"
EGO_PN="github.com/zaquestion/${PN}"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
# Deps that are not needed:
# github.com/cpuguy83/go-md2man
# github.com/davecgh/go-spew
# github.com/inconshreveable/mousetrap
# github.com/pmezard/go-difflib
# github.com/russross/blackfriday
# github.com/stretchr/testify
EGO_VENDOR=(
	"github.com/avast/retry-go 5469272"
	"github.com/fsnotify/fsnotify c282820"
	"github.com/gdamore/encoding b23993c"
	"github.com/gdamore/tcell 2f25810"
	"github.com/google/go-querystring 53e6ce1"
	"github.com/hashicorp/hcl ef8a98b"
	"github.com/lucasb-eyer/go-colorful 2312723"
	"github.com/lunixbochs/vtclean 2d01aa"
	"github.com/magiconair/properties c3beff4"
	"github.com/mattn/go-runewidth 9e777a8"
	"github.com/mitchellh/mapstructure 00c29f5"
	"github.com/pelletier/go-toml acdc450"
	"github.com/pkg/errors 645ef00"
	"github.com/rivo/tview f855bee"
	"github.com/spf13/afero 6364489"
	"github.com/spf13/cast 8965335"
	"github.com/spf13/cobra 6154259"
	"github.com/spf13/jwalterweatherman 7c0cea3"
	"github.com/spf13/pflag 583c0c0"
	"github.com/spf13/viper 1573881"
	"github.com/tcnksm/go-gitconfig d154598"
	"github.com/xanzy/go-gitlab 60ef0cd"
	"golang.org/x/crypto e73bf33 github.com/golang/crypto"
	"golang.org/x/sys 79b0c68 github.com/golang/sys"
	"golang.org/x/text f21a4df github.com/golang/text"
	"gopkg.in/yaml.v2 5420a8b github.com/go-yaml/yaml"
)

inherit golang-vcs-snapshot

DESCRIPTION="Lab wraps Git or Hub to easily interact with repositories on GitLab"
HOMEPAGE="https://zaquestion.github.io/lab"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror test" # test requires a proper git repository

LICENSE="Unlicense"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="pie"

RDEPEND="|| ( dev-vcs/git dev-vcs/hub )"

DOCS=( README.md )

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

QA_PRESTRIPPED="usr/bin/lab"

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w -X main.version=${GIT_COMMIT:0:10}"
	)
	go build "${mygoargs[@]}" || die
}

src_install() {
	dobin lab
	einstalldocs
}
