# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GIT_COMMIT="dca644d" # Change this when you update the ebuild
EGO_PN="github.com/senorprogrammer/${PN}"

inherit golang-vcs-snapshot

DESCRIPTION="A personal information dashboard for your terminal"
HOMEPAGE="https://wtfutil.com"
SRC_URI="https://${EGO_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DOCS=( README.md )

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

QA_PRESTRIPPED="usr/bin/wtf"

src_compile() {
	export GOPATH="${G}"
	local myldflags=( -s -w
		-X "main.version=v${PV}-${GIT_COMMIT}"
		-X "'main.date=$(date -u '+%FT%T%z')'"
	)
	local mygoargs=(
		-v -work -x
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)
	go build "${mygoargs[@]}" -o bin/wtf || die
}

src_install() {
	dobin bin/wtf
	einstalldocs
}

pkg_postinst() {
	einfo
	elog "See https://wtfutil.com/posts/configuration/ for configuration guide."
	einfo
}
