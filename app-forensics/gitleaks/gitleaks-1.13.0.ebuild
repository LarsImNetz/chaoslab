# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/zricethezav/${PN}"

inherit golang-vcs-snapshot

DESCRIPTION="Audit git repos for secrets"
HOMEPAGE="https://github.com/zricethezav/gitleaks"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="pie test"

DOCS=( CHANGELOG.md README.md )
QA_PRESTRIPPED="usr/bin/gitleaks"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	if use test; then
		# shellcheck disable=SC2086
		if has network-sandbox ${FEATURES}; then
			ewarn
			ewarn "The test phase requires 'network-sandbox' to be disabled in FEATURES"
			ewarn
			die "[network-sandbox] is enabled in FEATURES"
		fi
	fi
}

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w"
	)
	go build "${mygoargs[@]}" || die
}

src_test() {
	go test -v --race -cover ./... || die
}

src_install() {
	dobin gitleaks
	einstalldocs
}
