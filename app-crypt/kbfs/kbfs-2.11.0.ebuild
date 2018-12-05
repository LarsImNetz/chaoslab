# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/keybase/${PN}"

inherit golang-vcs-snapshot-r1

DESCRIPTION="Keybase Filesystem (KBFS)"
HOMEPAGE="https://keybase.io/docs/kbfs"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug git pie"

RDEPEND="
	app-crypt/gnupg
	sys-fs/fuse
"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

QA_PRESTRIPPED="usr/bin/.*"

src_compile() {
	export GOPATH="${G}"
	export GOBIN="${S}/bin"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie exe)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "$(usex !debug '-s -w' '')"
		-tags production
	)

	go install "${mygoargs[@]}" ./{kbfsfuse,kbfstool} || die

	if use git; then
		go build "${mygoargs[@]}" kbfsgit/git-remote-keybase || die
	fi
}

src_test() {
	go test -v ./test || die
}

src_install() {
	dobin bin/{kbfsfuse,kbfstool}
	use debug && dostrip -x /usr/bin/{kbfsfuse,kbfstool}

	if use git; then
		dobin git-remote-keybase
		use debug && dostrip -x /usr/bin/git-remote-keybase
	fi
}
