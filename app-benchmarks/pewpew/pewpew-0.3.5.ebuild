# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/bengadbois/${PN}"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
# Deps that are not needed:
# github.com/inconshreveable/mousetrap v1.0
# github.com/mattn/go-colorable v0.0.9
# github.com/mattn/go-isatty v0.0.3
EGO_VENDOR=(
	"github.com/dustin/go-humanize 9f541cc9db"
	"github.com/fatih/color v1.5.0"
	"github.com/fsnotify/fsnotify v1.4.2"
	"github.com/hashicorp/hcl 68e816d1c7"
	"github.com/lucasjones/reggen bed4659921"
	"github.com/magiconair/properties v1.7.3"
	"github.com/mitchellh/mapstructure d0303fe809"
	"github.com/pelletier/go-toml v1.0.1"
	"github.com/spf13/afero 3de492c3cd"
	"github.com/spf13/cast v1.1.0"
	"github.com/spf13/cobra bc69223348"
	"github.com/spf13/jwalterweatherman 12bd96e663"
	"github.com/spf13/pflag v1.0.0"
	"github.com/spf13/viper v1.0.0"
	"golang.org/x/net a04bdaca5b github.com/golang/net"
	"golang.org/x/sys ebfc5b4631 github.com/golang/sys"
	"golang.org/x/text 825fc78a2f github.com/golang/text"
	"gopkg.in/yaml.v2 eb3733d160 github.com/go-yaml/yaml"
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
IUSE="examples"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/pewpew"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_pretend() {
	if [[ "${MERGE_TYPE}" != binary ]]; then
		# shellcheck disable=SC2086
		(has test ${FEATURES} && has network-sandbox ${FEATURES}) && \
			die "The test phase requires 'network-sandbox' to be disabled in FEATURES"
	fi
}

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
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
		dodoc -r examples/*
		docompress -x "/usr/share/doc/${PF}/examples"
	fi
}
