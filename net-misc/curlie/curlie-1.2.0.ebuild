# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/rs/${PN}"
# Note: Keep EGO_VENDOR in sync with go.mod
# Deps that are not needed:
# github.com/akamensky/argparse 99676ba18c
# github.com/jessevdk/go-flags v1.4.0
EGO_VENDOR=(
	"golang.org/x/crypto 159ae71589 github.com/golang/crypto"
	"golang.org/x/sys 31355384c8 github.com/golang/sys"
)

inherit golang-vcs-snapshot-r1

DESCRIPTION="The power of curl, the ease of use of HTTPie"
HOMEPAGE="https://curlie.io/"
ARCHIVE_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="${ARCHIVE_URI} ${EGO_VENDOR_URI}"
RESTRICT="mirror test" # No tests available yet

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86" # Untested: arm arm64 x86
IUSE="debug pie"

RDEPEND="net-misc/curl"

DOCS=( README.md )
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
	go build "${mygoargs[@]}" || die
}

src_test() {
	go test -v -race ./... || die
}

src_install() {
	dobin curlie
	einstalldocs

	use debug && dostrip -x /usr/bin/curlie
}
