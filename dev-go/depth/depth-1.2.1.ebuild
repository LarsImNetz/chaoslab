# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/KyleBanks/depth"

inherit golang-vcs-snapshot

DESCRIPTION="Retrieve and visualize Go source code dependency trees"
HOMEPAGE="https://github.com/KyleBanks/depth"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

QA_PRESTRIPPED="usr/bin/depth"

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
	go build "${mygoargs[@]}" ./cmd/depth || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin depth
	dodoc README.md
}
