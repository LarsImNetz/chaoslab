# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Change this when you update the ebuild:
GIT_COMMIT="f9081acaad4ed98bee96ea49b403dc52d54b1b66"
EGO_PN="github.com/zaquestion/${PN}"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
EGO_VENDOR=(
	"github.com/avast/retry-go 1.0.1"
	#"github.com/cpuguy83/go-md2man v1.0.8"
	#"github.com/davecgh/go-spew v1.1.0"
	"github.com/fsnotify/fsnotify v1.4.7"
	"github.com/gdamore/encoding b23993cbb635"
	"github.com/gdamore/tcell 2f258105ca8c"
	#"github.com/golang/protobuf v1.1.0"
	"github.com/google/go-querystring 53e6ce116135"
	"github.com/hashicorp/hcl ef8a98b0bbce"
	#"github.com/inconshreveable/mousetrap v1.0"
	"github.com/lucasb-eyer/go-colorful 231272389856"
	"github.com/lunixbochs/vtclean 2d01aacdc34a"
	"github.com/magiconair/properties v1.7.6"
	"github.com/mattn/go-runewidth v0.0.2"
	"github.com/mitchellh/mapstructure 00c29f56e238"
	"github.com/pelletier/go-toml v1.1.0"
	"github.com/pkg/errors v0.8.0"
	#"github.com/pmezard/go-difflib v1.0.0"
	"github.com/rivo/tview f855bee0205c"
	#"github.com/russross/blackfriday v1.5.1"
	"github.com/spf13/afero v1.1.0"
	"github.com/spf13/cast v1.2.0"
	"github.com/spf13/cobra 615425954c3b"
	"github.com/spf13/jwalterweatherman 7c0cea34c8ec"
	"github.com/spf13/pflag v1.0.1"
	"github.com/spf13/viper 15738813a09d"
	#"github.com/stretchr/testify v1.2.1"
	"github.com/tcnksm/go-gitconfig v0.1.2"
	"github.com/xanzy/go-gitlab 8d21e61ce4a9"
	"golang.org/x/crypto e73bf333ef89 github.com/golang/crypto"
	"golang.org/x/net f4c29de78a2a github.com/golang/net"
	"golang.org/x/oauth2 3d292e4d0cdc github.com/golang/oauth2"
	"golang.org/x/sys 79b0c6888797 github.com/golang/sys"
	"golang.org/x/text v0.3.0 github.com/golang/text"
	#"google.golang.org/appengine v1.1.0 github.com/golang/appengine"
	"gopkg.in/yaml.v2 v2.2.1 github.com/go-yaml/yaml"
)

inherit golang-vcs-snapshot-r1

DESCRIPTION="Lab wraps Git or Hub to easily interact with repositories on GitLab"
HOMEPAGE="https://zaquestion.github.io/lab"
ARCHIVE_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="${ARCHIVE_URI} ${EGO_VENDOR_URI}"
RESTRICT="mirror test" # test requires a proper git repository

LICENSE="Unlicense"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86" # Untested: arm arm64 x86
IUSE="debug pie"

RDEPEND="|| ( dev-vcs/git dev-vcs/hub )"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "'main.version=v${PV}-${GIT_COMMIT:0:8}'"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie exe)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)
	go build "${mygoargs[@]}" || die
}

src_install() {
	dobin lab
	use debug && dostrip -x /usr/bin/lab
	einstalldocs
}
