# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GIT_COMMIT="f3d5190793" # Change this when you update the ebuild
EGO_PN="github.com/gohugoio/hugo"
# Note: Keep EGO_VENDOR in sync with go.mod
# Deps that are not needed:
# github.com/inconshreveable/mousetrap 76626ae9c9 #v1.0.0
# github.com/kr/pretty 73f6ac0b30 #v0.1.0
# github.com/magefile/mage 49bafb86c8 #v1.4.0
# github.com/nfnt/resize 83c6a99326
# gopkg.in/check.v1 788fd78401
EGO_VENDOR=(
	"github.com/BurntSushi/locker a6e239ea1c"
	"github.com/BurntSushi/toml a368813c5e"
	"github.com/PuerkitoBio/purell 0bcb03f4b4"
	"github.com/PuerkitoBio/urlesc de5bf2ad45"
	"github.com/alecthomas/assert 405dbfeb8e" # tests
	"github.com/alecthomas/chroma 5a473179cf"
	"github.com/alecthomas/colour 60882d9e27" # tests
	"github.com/alecthomas/repr 117648cd98" # tests
	"github.com/bep/debounce 844797fa1d"
	"github.com/bep/gitmap ecb6fe06db"
	"github.com/bep/go-tocss 2abb118dc8"
	"github.com/bep/mapstructure bb74f1db06"
	"github.com/chaseadamsio/goorgeous dcf1ef873b"
	"github.com/cpuguy83/go-md2man 20f5889cbd"
	"github.com/danwakefield/fnmatch cbb64ac3d9"
	"github.com/disintegration/imaging 0bd5694c78"
	"github.com/dlclark/regexp2 487489b64f"
	"github.com/eknkc/amber cdade1c073"
	"github.com/fsnotify/fsnotify c2828203cd"
	"github.com/fortytw2/leaktest a5ef70473c" # tests
	"github.com/gobwas/glob 5ccd90ef52"
	"github.com/gobuffalo/envy 3c96536452" # inderect
	"github.com/gorilla/websocket 66b9c49e59"
	"github.com/hashicorp/go-immutable-radix 27df80928b"
	"github.com/hashicorp/golang-lru 20f1fb78b0" # inderect
	"github.com/hashicorp/hcl 8cb6e5b959" # inderect
	"github.com/jdkato/prose 20d3663d4b"
	"github.com/joho/godotenv 23d116af35" # inderect
	"github.com/kyokomi/emoji 2e9a950733"
	"github.com/magiconair/properties c2353362d5" # inderect
	"github.com/markbates/inflect dd7de90c06"
	"github.com/mattn/go-isatty 6ca4dbf54d"
	"github.com/mattn/go-runewidth ce7b0b5c7b"
	"github.com/miekg/mmark fd2f6c1403"
	"github.com/mitchellh/hashstructure a38c501483"
	"github.com/mitchellh/mapstructure fa473d140e"
	"github.com/muesli/smartcrop f6ebaa786a"
	"github.com/nicksnyder/go-i18n 0dc1626d56"
	"github.com/olekukonko/tablewriter d4647c9c7a"
	"github.com/pelletier/go-toml c01d1270ff" # inderect
	"github.com/pkg/errors 645ef00459"
	"github.com/russross/blackfriday 46c73eb196"
	"github.com/sanity-io/litter ae543b7ba8" # tests
	"github.com/sergi/go-diff 1744e2970c" # tests
	"github.com/shurcooL/sanitized_anchor_name 86672fcb3f"
	"github.com/spf13/afero d40851caa0"
	"github.com/spf13/cast 8c9545af88"
	"github.com/spf13/cobra ef82de70bb"
	"github.com/spf13/fsync 12a01e648f"
	"github.com/spf13/jwalterweatherman 94f6ae3ed3"
	"github.com/spf13/nitro 24d7ef30a1"
	"github.com/spf13/pflag 298182f68c"
	"github.com/spf13/viper 8fb6420065"
	"github.com/stretchr/testify f2347ac6c9" # tests
	"github.com/tdewolff/minify/v2 5a7f15719c github.com/tdewolff/minify"
	"github.com/tdewolff/parse/v2 e17a58950f github.com/tdewolff/parse"
	"github.com/wellington/go-libsass 615eaa47ef" # sass
	"github.com/yosssi/ace ea038f4770"
	"golang.org/x/image c73c2afc3b github.com/golang/image"
	"golang.org/x/net 161cd47e91 github.com/golang/net" # inderect
	"golang.org/x/sync 1d60e4601c github.com/golang/sync"
	"golang.org/x/sys 90868a75fe github.com/golang/sys" # inderect
	"golang.org/x/text f21a4dfb5e github.com/golang/text"
	"gopkg.in/yaml.v2 5420a8b674 github.com/go-yaml/yaml"
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
IUSE="pie +sass"

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
		-tags "$(usex sass 'extended' '')"
	)
	go build "${mygoargs[@]}" || die

	./hugo gen man --dir="${T}"/man || die
	./hugo gen autocomplete --completionfile="${T}"/hugo || die
}

src_test() {
	# Remove tests that doesn't play nicely with portage's sandbox
	rm helpers/*_test.go || die
	rm hugolib/*_test.go || die
	rm releaser/git_test.go || die

	go test -v ./... || die
}

src_install() {
	dobin hugo
	doman "${T}"/man/*
	dobashcomp "${T}"/hugo
}
