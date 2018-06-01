# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/bengadbois/${PN}"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
# Deps that are not needed:
# github.com/inconshreveable/mousetrap 76626ae
# github.com/mattn/go-colorable 167de6b
# github.com/mattn/go-isatty 0360b2a
EGO_VENDOR=(
	"github.com/fatih/color 570b54c"
	"github.com/fsnotify/fsnotify 629574c"
	"github.com/hashicorp/hcl 68e816d"
	"github.com/lucasjones/reggen bed4659"
	"github.com/magiconair/properties be5ece7"
	"github.com/mitchellh/mapstructure d0303fe"
	"github.com/pelletier/go-toml 16398ba"
	"github.com/spf13/afero 3de492c"
	"github.com/spf13/cast acbeb36"
	"github.com/spf13/cobra bc69223"
	"github.com/spf13/jwalterweatherman 12bd96e"
	"github.com/spf13/pflag e57e3ee"
	"github.com/spf13/viper 25b30aa"
	"golang.org/x/net a04bdac github.com/golang/net"
	"golang.org/x/sys ebfc5b4 github.com/golang/sys"
	"golang.org/x/text 825fc78 github.com/golang/text"
	"gopkg.in/yaml.v2 eb3733d github.com/go-yaml/yaml"
)

inherit golang-vcs-snapshot

DESCRIPTION="Flexible HTTP command line stress tester for websites and web services"
HOMEPAGE="https://github.com/bengadbois/pewpew"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="examples test"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/pewpew"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	# shellcheck disable=SC2086
	if use test; then
		has network-sandbox $FEATURES && \
			die "The test phase requires 'network-sandbox' to be disabled in FEATURES"
	fi
}

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
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
	dobin pewpew
	einstalldocs

	if use examples; then
		docinto examples
		dodoc -r examples/config.{json,toml}
		docompress -x "/usr/share/doc/${PF}/examples"
	fi
}
