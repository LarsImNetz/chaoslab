# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

#TODO: Add an init script!

EGO_VENDOR=(
	"github.com/alexcesaro/log 61e6862"
	"github.com/dustin/go-humanize 2fcb520"
	"github.com/howeyc/gopass 26c6e11"
	"github.com/jessevdk/go-flags f2785f5"
	"github.com/shazow/rateio e8e0088"
	"golang.org/x/crypto 9419663 github.com/golang/crypto"
	"golang.org/x/sys ebfc5b4 github.com/golang/sys"
)

inherit golang-vcs-snapshot

EGO_PN="github.com/shazow/${PN}"
DESCRIPTION="A chat over SSH server written in Go"
HOMEPAGE="https://github.com/shazow/ssh-chat"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RESTRICT="mirror strip"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local GOLDFLAGS="-s -w \
		-X main.Version=${PV}"

	go build -v -ldflags "${GOLDFLAGS}" \
		./cmd/ssh-chat || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin ssh-chat
	dodoc README.md
}
