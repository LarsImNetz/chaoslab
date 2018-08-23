# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GIT_COMMIT="7ef5096" # Change this when you update the ebuild
EGO_PN="github.com/gohugoio/hugo"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
# Deps that are not needed:
# github.com/alecthomas/assert 405dbfe
# github.com/alecthomas/colour 60882d9
# github.com/alecthomas/repr ead2165
# github.com/davecgh/go-spew 346938d
# github.com/fortytw2/leaktest a5ef704
# github.com/inconshreveable/mousetrap 76626ae
# github.com/magefile/mage 2f97430
# github.com/mattn/go-isatty 0360b2a
# github.com/pmezard/go-difflib 792786c
# github.com/sanity-io/litter ae543b7
# github.com/sergi/go-diff 1744e29
# github.com/stretchr/testify f35b8ab
# github.com/wellington/go-libsass 615eaa4
EGO_VENDOR=(
	"github.com/BurntSushi/locker a6e239e"
	"github.com/BurntSushi/toml a368813"
	"github.com/PuerkitoBio/purell 0bcb03f"
	"github.com/PuerkitoBio/urlesc de5bf2a"
	"github.com/alecthomas/chroma 5d7fef2"
	"github.com/bep/debounce 844797fa"
	"github.com/bep/gitmap ecb6fe0"
	"github.com/bep/go-tocss 2abb118"
	"github.com/chaseadamsio/goorgeous dcf1ef8"
	"github.com/cpuguy83/go-md2man a65d4d2"
	"github.com/danwakefield/fnmatch cbb64ac"
	"github.com/disintegration/imaging dd50a3e"
	"github.com/dlclark/regexp2 487489b"
	"github.com/eknkc/amber cdade1c"
	"github.com/fsnotify/fsnotify c282820"
	"github.com/gobwas/glob 5ccd90e"
	"github.com/gorilla/websocket ea4d1f6"
	"github.com/hashicorp/go-immutable-radix 7f3cd43"
	"github.com/hashicorp/golang-lru 0fb14ef"
	"github.com/hashicorp/hcl ef8a98b"
	"github.com/jdkato/prose 20d3663"
	"github.com/kyokomi/emoji 2e9a950"
	"github.com/magiconair/properties c235336"
	"github.com/markbates/inflect a12c3ae"
	"github.com/mattn/go-runewidth 9e777a8"
	"github.com/miekg/mmark fd2f6c1"
	"github.com/mitchellh/hashstructure 2bca23e"
	"github.com/mitchellh/mapstructure f15292f"
	"github.com/muesli/smartcrop f6ebaa7"
	"github.com/nicksnyder/go-i18n 0dc1626"
	"github.com/olekukonko/tablewriter d4647c9"
	"github.com/pelletier/go-toml c01d127"
	"github.com/russross/blackfriday 46c73eb"
	"github.com/shurcooL/sanitized_anchor_name 86672fc"
	"github.com/spf13/afero 787d034"
	"github.com/spf13/cast 8965335"
	"github.com/spf13/cobra ef82de7"
	"github.com/spf13/fsync 12a01e6"
	"github.com/spf13/jwalterweatherman 7c0cea3"
	"github.com/spf13/nitro 24d7ef3"
	"github.com/spf13/pflag 583c0c0"
	"github.com/spf13/viper 907c19d"
	"github.com/tdewolff/minify 8d72a41"
	"github.com/tdewolff/parse d739d6f"
	"github.com/yosssi/ace ea038f4"
	"golang.org/x/image c73c2af github.com/golang/image"
	"golang.org/x/net f4c29de github.com/golang/net"
	"golang.org/x/sync 1d60e46 github.com/golang/sync"
	"golang.org/x/sys 3b87a42 github.com/golang/sys"
	"golang.org/x/text cb67308 github.com/golang/text"
	"gopkg.in/yaml.v2 5420a8b github.com/go-yaml/yaml"
)

inherit bash-completion-r1 golang-vcs-snapshot

DESCRIPTION="A static HTML and CSS website generator written in Go"
HOMEPAGE="https://gohugo.io"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="bash-completion pie"

QA_PRESTRIPPED="usr/bin/hugo"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local myldflags=( -s -w
		-X "${EGO_PN}/hugolib.CommitHash=${GIT_COMMIT}"
		-X "${EGO_PN}/hugolib.BuildDate=$(date -u '+%FT%T%z')"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)
	go build "${mygoargs[@]}" || die

	./hugo gen man --dir="${T}"/man || die

	if use bash-completion; then
		./hugo gen autocomplete --completionfile="${T}"/hugo || die
	fi
}

src_install() {
	dobin hugo
	doman "${T}"/man/*
	use bash-completion && dobashcomp "${T}"/hugo
}
