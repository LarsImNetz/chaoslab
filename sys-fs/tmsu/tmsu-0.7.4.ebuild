# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# Snapshot taken on 2018.11.24
EGO_VENDOR=(
	"github.com/hanwen/go-fuse c029b69a13"
	"github.com/mattn/go-sqlite3 v1.10.0"
	"golang.org/x/sys 62eef0e2fa github.com/golang/sys"
)

inherit golang-vcs-snapshot

EGO_PN="github.com/oniony/TMSU"
DESCRIPTION="Files tagger and virtual tag-based filesystem"
HOMEPAGE="https://github.com/oniony/TMSU"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="pie"

QA_PRESTRIPPED="usr/bin/tmsu"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_prepare() {
	# Move the sources from src/${EGO_PN} into ${S}
	mv src/${EGO_PN}/* ./ || die

	# We will only use make for tests, so let's silence the "compile".
	sed -i "s/ compile//g" Makefile || die

	default
}

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "-s -w"
		-o ./bin/tmsu
	)
	go build "${mygoargs[@]}" || die
}

src_test() {
	local PATH="${S}/bin:$PATH"
	default
}

src_install() {
	dosbin misc/bin/mount.tmsu
	dobin misc/bin/tmsu-*
	dobin bin/tmsu

	doman misc/man/tmsu.1

	insinto /usr/share/zsh/site-functions
	doins misc/zsh/_tmsu
}
