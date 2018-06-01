# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit golang-vcs-snapshot

EGO_PN="github.com/yudai/gotty"
DESCRIPTION="A simple command line tool that turns your CLI tools into web applications"
HOMEPAGE="https://github.com/yudai/gotty"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

QA_PRESTRIPPED="usr/bin/gotty"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w
		-X main.version=${PV}
		-X main.commit=${GIT_COMMIT}
		-X main.buildstamp=$(date -u '+%s')"
	)
	go build "${mygoargs[@]}" || die
}

src_install() {
	dobin gotty
	dodoc README.md
}
