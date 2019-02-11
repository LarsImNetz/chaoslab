# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/zricethezav/${PN}"

inherit golang-vcs-snapshot-r1

DESCRIPTION="Audit git repos for secrets"
HOMEPAGE="https://github.com/zricethezav/gitleaks"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror test" # test requires a GITHUB_TOKEN

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86" # Untested: arm arm64 x86
IUSE="debug pie static"

DOCS=( CHANGELOG.md README.md )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"
	(use static && ! use pie) && export CGO_ENABLED=0
	(use static && use pie) && CGO_LDFLAGS+=" -static"

	local mygoargs=(
		-v -work -x
		-buildmode "$(usex pie pie exe)"
		-asmflags "all=-trimpath=${S}"
		-gcflags "all=-trimpath=${S}"
		-ldflags "$(usex !debug '-s -w' '')"
		-tags "$(usex static 'netgo' '')"
		-installsuffix "$(usex static 'netgo' '')"
	)

	go build "${mygoargs[@]}" || die
}

src_install() {
	dobin gitleaks
	use debug && dostrip -x /usr/bin/gitleaks
	einstalldocs
}
