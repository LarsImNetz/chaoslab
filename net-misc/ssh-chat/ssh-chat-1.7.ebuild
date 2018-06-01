# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

#TODO: Add an init script!

# Note: Keep EGO_VENDOR in sync with Gopkg.lock
EGO_VENDOR=(
	"github.com/alexcesaro/log 61e6862"
	"github.com/howeyc/gopass bf9dde6"
	"github.com/jessevdk/go-flags 96dc062"
	"github.com/shazow/rateio e8e0088"
	"golang.org/x/crypto ee41a25 github.com/golang/crypto"
	"golang.org/x/sys 2c42eef github.com/golang/sys"
)

inherit golang-vcs-snapshot

EGO_PN="github.com/shazow/${PN}"
DESCRIPTION="A chat over SSH server written in Go"
HOMEPAGE="https://github.com/shazow/ssh-chat"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror strip"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

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
