# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/getantibody/${PN}"
# Note: Keep EGO_VENDOR in sync with go.mod
EGO_VENDOR=(
	"github.com/alecthomas/kingpin a39589180ebd"
	"github.com/alecthomas/template a0175ee3bccc"
	"github.com/alecthomas/units 2efee857e7cf"
	"github.com/caarlos0/gohome 75f08ebc60b1"
	"github.com/getantibody/folder v1.0.0"
	"github.com/stretchr/testify v1.2.2"
	"golang.org/x/crypto 1a580b3eff78 github.com/golang/crypto"
	"golang.org/x/net 2491c5de3490 github.com/golang/net"
	"golang.org/x/sync 1d60e4601c6f github.com/golang/sync"
	"golang.org/x/sys 7c87d13f8e83 github.com/golang/sys"
)

inherit golang-vcs-snapshot-r1

DESCRIPTION="The fastest shell plugin manager"
HOMEPAGE="https://getantibody.github.io"
ARCHIVE_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="${ARCHIVE_URI} ${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug pie"

RDEPEND="
	app-shells/zsh[unicode]
	dev-vcs/git
"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/.*"

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
	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "main.version=${PV}"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie exe)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)
	go build "${mygoargs[@]}" || die
}

src_test() {
	go test -v -failfast -race ./... || die
}

src_install() {
	dobin antibody
	use debug && dostrip -x /usr/bin/antibody
	einstalldocs
}
