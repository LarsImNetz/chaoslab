# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/getantibody/antibody"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
# Deps that are not needed:
# github.com/davecgh/go-spew
# github.com/pmezard/go-difflib
EGO_VENDOR=(
	"github.com/pierrre/gotestcover 924dca7" #for tests
	"github.com/alecthomas/kingpin a395891"
	"github.com/alecthomas/template a0175ee"
	"github.com/alecthomas/units 2efee85"
	"github.com/caarlos0/gohome c08fdeb"
	"github.com/getantibody/folder 479aa91"
	"github.com/stretchr/testify 12b6f73"
	"golang.org/x/crypto 1a580b3 github.com/golang/crypto"
	"golang.org/x/net 2491c5d github.com/golang/net"
	"golang.org/x/sync 1d60e46 github.com/golang/sync"
	"golang.org/x/sys 7c87d13 github.com/golang/sys"
)

inherit golang-vcs-snapshot

DESCRIPTION="The fastest shell plugin manager"
HOMEPAGE="https://getantibody.github.io"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="pie test"

RDEPEND="app-shells/zsh[unicode]
	dev-vcs/git"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/antibody"

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
	# shellcheck disable=SC2207
	local mygoargs=(
		-v -work -x
		$(usex pie '-buildmode=pie' '')
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w -X main.version=${PV}"
	)
	go build "${mygoargs[@]}" || die

	if use test; then
		go install ./vendor/github.com/pierrre/gotestcover || die
	fi
}

src_test() {
	local PATH="${G}/bin:$PATH"
	default
}

src_install() {
	dobin antibody
	einstalldocs
}
