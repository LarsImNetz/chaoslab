# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# Change this when you update the ebuild:
GIT_COMMIT="f9081acaad"
EGO_PN="github.com/zaquestion/${PN}"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
# Deps that are not needed:
# github.com/cpuguy83/go-md2man
# github.com/davecgh/go-spew
# github.com/golang/protobuf
# github.com/inconshreveable/mousetrap
# github.com/pmezard/go-difflib
# github.com/russross/blackfriday
# github.com/stretchr/testify
# google.golang.org/appengine
EGO_VENDOR=(
	"github.com/avast/retry-go 5469272a81"
	"github.com/fsnotify/fsnotify c2828203cd"
	"github.com/gdamore/encoding b23993cbb6"
	"github.com/gdamore/tcell 2f258105ca"
	"github.com/google/go-querystring 53e6ce1161"
	"github.com/hashicorp/hcl ef8a98b0bb"
	"github.com/lucasb-eyer/go-colorful 2312723898"
	"github.com/lunixbochs/vtclean 2d01aacdc3"
	"github.com/magiconair/properties c3beff4c23"
	"github.com/mattn/go-runewidth 9e777a8366"
	"github.com/mitchellh/mapstructure 00c29f56e2"
	"github.com/pelletier/go-toml acdc450948"
	"github.com/pkg/errors 645ef00459"
	"github.com/rivo/tview f855bee020"
	"github.com/spf13/afero 63644898a8"
	"github.com/spf13/cast 8965335b8c"
	"github.com/spf13/cobra 615425954c"
	"github.com/spf13/jwalterweatherman 7c0cea34c8"
	"github.com/spf13/pflag 583c0c0531"
	"github.com/spf13/viper 15738813a0"
	"github.com/tcnksm/go-gitconfig d154598bac"
	"github.com/xanzy/go-gitlab 8d21e61ce4"
	"golang.org/x/crypto e73bf333ef github.com/golang/crypto"
	"golang.org/x/net f4c29de78a github.com/golang/net"
	"golang.org/x/oauth2 3d292e4d0c github.com/golang/oauth2"
	"golang.org/x/sys 79b0c68887 github.com/golang/sys"
	"golang.org/x/text f21a4dfb5e github.com/golang/text"
	"gopkg.in/yaml.v2 5420a8b674 github.com/go-yaml/yaml"
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
QA_PRESTRIPPED="usr/bin/lab"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "-s -w -X main.version=${GIT_COMMIT}"
	)
	go build "${mygoargs[@]}" || die
}

src_install() {
	dobin lab
	einstalldocs
}
