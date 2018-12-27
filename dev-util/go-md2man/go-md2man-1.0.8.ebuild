# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/cpuguy83/${PN}"

inherit golang-vcs-snapshot

DESCRIPTION="A utility to convert markdown to man pages"
HOMEPAGE="https://github.com/cpuguy83/go-md2man"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="pie"

QA_PRESTRIPPED="usr/bin/go-md2man"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local PATH="${S}:$PATH"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "-s -w"
	)
	go build "${mygoargs[@]}" || die
	go-md2man -in go-md2man.1.md -out go-md2man.1
}

src_install() {
	dobin go-md2man
	doman go-md2man.1
}
