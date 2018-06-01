# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/peco/peco"
# Note: Keep EGO_VENDOR in sync with glide.lock
# Deps that are not needed:
# golang.org/x/crypto
EGO_VENDOR=(
	"github.com/google/btree 0c3044b"
	"github.com/jessevdk/go-flags 8bc97d6"
	"github.com/lestrrat/go-pdebug 2e6eaaa"
	"github.com/mattn/go-runewidth 737072b"
	"github.com/nsf/termbox-go e2050e4"
	"github.com/pkg/errors 248dadf"
	"github.com/stretchr/testify 18a02ba"
)

inherit golang-vcs-snapshot

DESCRIPTION="Simplistic interactive filtering tool"
HOMEPAGE="https://github.com/peco/peco"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DOCS=( Changes README.md )
QA_PRESTRIPPED="usr/bin/peco"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w"
	)
	go build "${mygoargs[@]}" ./cmd/peco || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin peco
	einstalldocs
}
