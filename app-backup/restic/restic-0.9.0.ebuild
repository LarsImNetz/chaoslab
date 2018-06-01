# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/${PN}/${PN}"

inherit bash-completion-r1 golang-vcs-snapshot

DESCRIPTION="A backup program that is fast, efficient and secure"
HOMEPAGE="https://restic.github.io"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="bash-completion doc pie zsh-completion"

RDEPEND="sys-fs/fuse:0
	zsh-completion? ( app-shells/zsh )"
DEPEND="doc? ( dev-python/sphinx )"

DOCS=( README.rst )
QA_PRESTRIPPED="usr/bin/restic"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	# shellcheck disable=SC2207
	local mygoargs=(
		-v -work -x
		$(usex pie '-buildmode=pie' '')
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w -X main.version=${PV}"
	)
	go build "${mygoargs[@]}" ./cmd/restic || die

	if use doc; then
		HTML_DOCS=( doc/_build/html/. )
		emake -C doc html
	fi
}

src_test() {
	go test -timeout 30m -v -work -x \
		./cmd/... ./internal/... || die
}

src_install() {
	dobin restic
	einstalldocs

	doman doc/man/*.1

	use bash-completion && \
		newbashcomp doc/bash-completion.sh restic

	if use zsh-completion; then
		insinto /usr/share/zsh/site-functions
		newins doc/zsh-completion.zsh _restic
	fi
}
