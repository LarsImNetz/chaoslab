# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Change this when you update the ebuild
GIT_COMMIT="3a63001f732b4f330fa09b5b13e6287f9e9627c9"
EGO_PN="github.com/senorprogrammer/${PN}"

inherit golang-vcs-snapshot-r1

DESCRIPTION="A personal information dashboard for your terminal"
HOMEPAGE="https://wtfutil.com"
SRC_URI="https://${EGO_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86" # Untested: arm arm64 x86
IUSE="debug pie"

DOCS=( README.md )

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

QA_PRESTRIPPED="usr/bin/.*"

src_compile() {
	export GOPATH="${G}"
	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "main.version=v${PV}-${GIT_COMMIT:0:6}"
		-X "'main.date=$(date -u '+%FT%T%z')'"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie exe)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
		-o bin/wtf
	)
	go build "${mygoargs[@]}" || die
}

src_install() {
	dobin bin/wtf
	use debug && dostrip -x /usr/bin/wtf
	einstalldocs
}

pkg_postinst() {
	einfo
	elog "See https://wtfutil.com/posts/configuration/ for configuration guide"
	einfo
}
