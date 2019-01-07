# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/${PN}/${PN}"

inherit bash-completion-r1 golang-vcs-snapshot-r1

DESCRIPTION="A backup program that is fast, efficient and secure"
HOMEPAGE="https://restic.github.io"
SRC_URI="https://${EGO_PN}/releases/download/v${PV}/${P}.tar.gz"
RESTRICT="mirror"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug doc pie"

RDEPEND="sys-fs/fuse:0"
DEPEND="doc? ( dev-python/sphinx )"

DOCS=( README.rst )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "main.version=${PV}"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie exe)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)
	go build "${mygoargs[@]}" ./cmd/restic || die

	if use doc; then
		HTML_DOCS=( doc/_build/html/. )
		emake -C doc html
	fi
}

src_test() {
	go test -v ./cmd/... ./internal/... || die
}

src_install() {
	dobin restic
	use debug && dostrip -x /usr/bin/restic

	doman doc/man/*.1
	newbashcomp doc/bash-completion.sh restic

	insinto /usr/share/zsh/site-functions
	newins doc/zsh-completion.zsh _restic

	einstalldocs
}
