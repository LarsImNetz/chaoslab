# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="ekyu.moe/${PN}"
# Note: Keep EGO_VENDOR in sync with go.mod
EGO_VENDOR=(
	"github.com/ebfe/keccak 5cc570678d1b"
	"github.com/paxos-bankchain/moneroutil 33d7e0c11a62"
	"golang.org/x/crypto c126467f60eb github.com/golang/crypto"
)

inherit golang-vcs-snapshot-r1

DESCRIPTION="Generate vanity address for CryptoNote currency"
HOMEPAGE="https://github.com/Equim-chan/vanity-monero"
ARCHIVE_URI="https://github.com/Equim-chan/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="${ARCHIVE_URI} ${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86" # Untested: arm arm64 x86
IUSE="debug pie"

DOCS=( README.adoc )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie exe)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "$(usex !debug '-s -w' '')"
	)
	go build "${mygoargs[@]}" ./cmd/vanity-monero || die
}

src_install() {
	dobin vanity-monero
	use debug && dostrip -x /usr/bin/vanity-monero
	einstalldocs
}
