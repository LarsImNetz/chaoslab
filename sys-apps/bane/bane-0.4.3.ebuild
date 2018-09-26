# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GIT_COMMIT="59179759f9" # Change this when you update the ebuild
EGO_PN="github.com/genuinetools/${PN}"

inherit golang-vcs-snapshot

DESCRIPTION="AppArmor profile generator for docker containers"
HOMEPAGE="https://github.com/genuinetools/bane"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/bane"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local myldflags=( -s -w
		-X "${EGO_PN}/version.GITCOMMIT=${GIT_COMMIT}"
		-X "${EGO_PN}/version.VERSION=${PV}"
	)
	local mygoargs=(
		-v -work -x
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)
	go build "${mygoargs[@]}" || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin bane
	einstalldocs
}
