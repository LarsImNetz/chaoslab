# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GIT_COMMIT="f3d5190793" # Change this when you update the ebuild
EGO_PN="github.com/gohugoio/hugo"
# Note: Keep EGO_VENDOR in sync with go.mod
# Deps that are not needed:
# github.com/inconshreveable/mousetrap v1.0.0
# github.com/kr/pretty v0.1.0
# github.com/magefile/mage v1.4.0
# github.com/nfnt/resize 83c6a99326
# gopkg.in/check.v1 788fd78401
EGO_VENDOR=(
	"github.com/BurntSushi/locker a6e239ea1c"
	"github.com/BurntSushi/toml a368813c5e"
	"github.com/PuerkitoBio/purell v1.1.0"
	"github.com/PuerkitoBio/urlesc de5bf2ad45"
	"github.com/alecthomas/assert 405dbfeb8e" # tests
	"github.com/alecthomas/chroma v0.6.0"
	"github.com/alecthomas/colour 60882d9e27" # tests
	"github.com/alecthomas/repr 117648cd98" # tests
	"github.com/bep/debounce v1.1.0"
	"github.com/bep/gitmap v1.0.0"
	"github.com/bep/go-tocss v0.5.0"
	"github.com/bep/mapstructure bb74f1db06"
	"github.com/chaseadamsio/goorgeous v1.1.0"
	"github.com/cpuguy83/go-md2man v1.0.8"
	"github.com/danwakefield/fnmatch cbb64ac3d9"
	"github.com/disintegration/imaging v1.5.0"
	"github.com/dlclark/regexp2 v1.1.6"
	"github.com/eknkc/amber cdade1c073"
	"github.com/fortytw2/leaktest v1.2.0" # tests
	"github.com/fsnotify/fsnotify v1.4.7"
	"github.com/gobwas/glob v0.2.3"
	"github.com/gobuffalo/envy v1.6.8" # inderect
	"github.com/gorilla/websocket v1.4.0"
	"github.com/hashicorp/go-immutable-radix v1.0.0"
	"github.com/hashicorp/golang-lru v0.5.0" # inderect
	"github.com/hashicorp/hcl v1.0.0" # inderect
	"github.com/jdkato/prose v1.1.0"
	"github.com/joho/godotenv v1.3.0" # inderect
	"github.com/kyokomi/emoji v1.5.1"
	"github.com/magiconair/properties v1.8.0" # inderect
	"github.com/markbates/inflect v1.0.0"
	"github.com/mattn/go-isatty v0.0.4"
	"github.com/mattn/go-runewidth v0.0.3"
	"github.com/miekg/mmark v1.3.6"
	"github.com/mitchellh/hashstructure v1.0.0"
	"github.com/mitchellh/mapstructure v1.0.0"
	"github.com/muesli/smartcrop f6ebaa786a"
	"github.com/nicksnyder/go-i18n v1.10.0"
	"github.com/olekukonko/tablewriter d4647c9c7a"
	"github.com/pelletier/go-toml v1.2.0" # inderect
	"github.com/pkg/errors v0.8.0"
	"github.com/russross/blackfriday 46c73eb196"
	"github.com/sanity-io/litter v1.1.0" # tests
	"github.com/sergi/go-diff v1.0.0" # tests
	"github.com/shurcooL/sanitized_anchor_name 86672fcb3f"
	"github.com/spf13/afero v1.1.2"
	"github.com/spf13/cast v1.3.0"
	"github.com/spf13/cobra v0.0.3"
	"github.com/spf13/fsync 12a01e648f"
	"github.com/spf13/jwalterweatherman 94f6ae3ed3"
	"github.com/spf13/nitro 24d7ef30a1"
	"github.com/spf13/pflag v1.0.3"
	"github.com/spf13/viper v1.2.0"
	"github.com/stretchr/testify f2347ac6c9" # tests
	"github.com/tdewolff/minify/v2 v2.3.7 github.com/tdewolff/minify"
	"github.com/tdewolff/parse/v2 v2.3.5 github.com/tdewolff/parse" # inderect
	"github.com/wellington/go-libsass 615eaa47ef" # sass
	"github.com/yosssi/ace v0.0.5"
	"golang.org/x/image c73c2afc3b github.com/golang/image"
	"golang.org/x/net 161cd47e91 github.com/golang/net" # inderect
	"golang.org/x/sync 1d60e4601c github.com/golang/sync"
	"golang.org/x/sys 90868a75fe github.com/golang/sys" # inderect
	"golang.org/x/text v0.3.0 github.com/golang/text"
	"gopkg.in/yaml.v2 v2.2.1 github.com/go-yaml/yaml"
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
