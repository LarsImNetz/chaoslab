# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/keybase/kbfs"

inherit golang-vcs-snapshot

DESCRIPTION="Keybase Filesystem (KBFS)"
HOMEPAGE="https://keybase.io/docs/kbfs"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="git pie"

RDEPEND="app-crypt/gnupg
	sys-fs/fuse"

QA_PRESTRIPPED="usr/bin/kbfsfuse
	usr/bin/kbfstool
	usr/bin/git-remote-keybase"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	export GOBIN="${S}/bin"
	# shellcheck disable=SC2207
	local mygoargs=(
		-v -work -x
		$(usex pie '-buildmode=pie' '')
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w"
		-tags production
	)
	go install "${mygoargs[@]}" \
		./{kbfsfuse,kbfstool} || die

	if use git; then
		go build "${mygoargs[@]}" \
			./kbfsgit/git-remote-keybase || die
	fi
}

src_install() {
	dobin bin/{kbfsfuse,kbfstool}
	use git && dobin git-remote-keybase
}
