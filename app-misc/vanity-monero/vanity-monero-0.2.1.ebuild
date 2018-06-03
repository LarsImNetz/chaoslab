# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="ekyu.moe/${PN}"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
EGO_VENDOR=(
	"github.com/ebfe/keccak 5cc5706"
	"github.com/paxos-bankchain/moneroutil 33d7e0c"
	"golang.org/x/crypto ab81327 github.com/golang/crypto"
)

inherit golang-vcs-snapshot

DESCRIPTION="Generate vanity address for CryptoNote currency"
HOMEPAGE="https://github.com/Equim-chan/vanity-monero"
SRC_URI="https://github.com/Equim-chan/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DOCS=( README.adoc )
QA_PRESTRIPPED="usr/bin/vanity-monero"

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
	go build "${mygoargs[@]}" ./cmd/vanity-monero || die
}

src_install() {
	dobin vanity-monero
	einstalldocs
}
