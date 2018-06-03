# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/heppu/${PN}"
EGO_VENDOR=(
	"github.com/fatih/color 2d68451"
	"github.com/heppu/rawterm f84711c"
	"github.com/k0kubun/go-ansi 3bf9e29"
	"github.com/mitchellh/go-ps 4fdf99a"
)

inherit golang-vcs-snapshot

DESCRIPTION="An interactive process killer"
HOMEPAGE="https://github.com/heppu/gkill"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

QA_PRESTRIPPED="usr/bin/gkill"

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
	go build "${mygoargs[@]}" || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin gkill
	dodoc README.md
}
