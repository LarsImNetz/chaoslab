# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GIT_COMMIT="171caf2" # Change this when you update the ebuild
EGO_PN="github.com/gohugoio/hugo"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
# Deps that are not needed:
# github.com/davecgh/go-spew 346938d
# github.com/fortytw2/leaktest a5ef704
# github.com/inconshreveable/mousetrap 76626ae
# github.com/magefile/mage 2f97430
# github.com/pmezard/go-difflib 792786c
# github.com/sanity-io/litter ae543b7
# github.com/stretchr/testify 12b6f73
EGO_VENDOR=(
	"github.com/BurntSushi/toml a368813"
	"github.com/PuerkitoBio/purell 0bcb03f"
	"github.com/PuerkitoBio/urlesc de5bf2a"
	"github.com/alecthomas/chroma 6b1131c"
	"github.com/bep/debounce 844797fa"
	"github.com/bep/gitmap 012701e"
	"github.com/chaseadamsio/goorgeous dcf1ef8"
	"github.com/cpuguy83/go-md2man 20f5889"
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
	"github.com/kyokomi/emoji 7e06b23"
	"github.com/magiconair/properties c3beff"
	"github.com/markbates/inflect a12c3ae"
	"github.com/mattn/go-runewidth 9e777a8"
	"github.com/miekg/mmark fd2f6c1"
	"github.com/mitchellh/mapstructure 00c29f5"
	"github.com/muesli/smartcrop f6ebaa7"
	"github.com/nicksnyder/go-i18n 0dc1626"
	"github.com/olekukonko/tablewriter b8a9be0"
	"github.com/pelletier/go-toml acdc450"
	"github.com/russross/blackfriday 55d61fa"
	"github.com/shurcooL/sanitized_anchor_name 86672fc"
	"github.com/spf13/afero 6364489"
	"github.com/spf13/cast 8965335"
	"github.com/spf13/cobra a1f051b"
	"github.com/spf13/fsync 12a01e6"
	"github.com/spf13/jwalterweatherman 7c0cea3"
	"github.com/spf13/nitro 24d7ef3"
	"github.com/spf13/pflag e57e3ee"
	"github.com/spf13/viper b5e8006"
	"github.com/yosssi/ace ea038f4"
	"golang.org/x/image f315e44 github.com/golang/image"
	"golang.org/x/net 61147c4 github.com/golang/net"
	"golang.org/x/sync 1d60e46 github.com/golang/sync"
	"golang.org/x/sys 3b87a42 github.com/golang/sys"
	"golang.org/x/text 2cb4393 github.com/golang/text"
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
	# shellcheck disable=SC2207
	local mygoargs=(
		-v -work -x
		$(usex pie '-buildmode=pie' '')
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w
			-X ${EGO_PN}/hugolib.CommitHash=${GIT_COMMIT}
			-X ${EGO_PN}/hugolib.BuildDate=$(date +%FT%T%z)"
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

	if use bash-completion; then
		dobashcomp "${T}"/hugo
	fi
}
