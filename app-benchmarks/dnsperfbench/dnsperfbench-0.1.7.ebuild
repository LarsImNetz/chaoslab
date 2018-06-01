# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/turbobytes/${PN}"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
# Deps that are not needed:
# golang.org/x/crypto
EGO_VENDOR=(
	"github.com/mattn/go-runewidth 9e777a8"
	"github.com/miekg/dns 83c435c"
	"github.com/montanaflynn/stats eeaced0"
	"github.com/olekukonko/tablewriter d5dd8a5"
	"golang.org/x/net d41e81 github.com/golang/net"
	"golang.org/x/sync 1d60e46 github.com/golang/sync"
)

inherit golang-vcs-snapshot

DESCRIPTION="A command line tool to compare performance of DNS resolvers"
HOMEPAGE="https://ismydnsfast.com/"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/dnsperfbench"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w
			-X main.versionString=${PV}
			-X 'main.goVersionString=$(go version)'"
	)
	go build "${mygoargs[@]}" || die
}

src_install() {
	dobin dnsperfbench
	einstalldocs
}
