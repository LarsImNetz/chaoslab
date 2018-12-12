# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/turbobytes/${PN}"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
EGO_VENDOR=(
	"github.com/mattn/go-runewidth v0.0.2"
	"github.com/miekg/dns v1.0.5"
	"github.com/montanaflynn/stats 0.2.0"
	"github.com/olekukonko/tablewriter d5dd8a50526a"
	#"golang.org/x/crypto d6449816ce06 github.com/golang/crypto"
	"golang.org/x/net d41e8174641f github.com/golang/net"
	"golang.org/x/sync 1d60e4601c6f github.com/golang/sync"
)

inherit golang-vcs-snapshot-r1

DESCRIPTION="A command line tool to compare performance of DNS resolvers"
HOMEPAGE="https://ismydnsfast.com/"
ARCHIVE_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="${ARCHIVE_URI} ${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86" # Untested: arm arm64 x86
IUSE="debug pie"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "main.versionString=${PV}"
		-X "'main.goVersionString=$(go version)'"
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

src_install() {
	dobin dnsperfbench
	use debug && dostrip -x /usr/bin/dnsperfbench
	einstalldocs
}
