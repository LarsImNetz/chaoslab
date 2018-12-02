# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/oniony/TMSU"
EGO_VENDOR=(
	# Snapshot taken on 2018.12.2
	"github.com/hanwen/go-fuse c029b69a13a7"
	"github.com/mattn/go-sqlite3 v1.10.0"
	"golang.org/x/sys 4ed8d59d0b35 github.com/golang/sys"
)

inherit golang-vcs-snapshot-r1

DESCRIPTION="Files tagger and virtual tag-based filesystem"
HOMEPAGE="https://github.com/oniony/TMSU"
ARCHIVE_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI="${ARCHIVE_URI} ${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86" # Untested: arm arm64
IUSE="debug pie"

QA_PRESTRIPPED="usr/bin/.*"

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
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie exe)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "$(usex !debug '-s -w' '')"
		-o ./bin/tmsu
	)
	go build "${mygoargs[@]}" || die
}

src_test() {
	local PATH="${S}/bin:$PATH"
	default
}

src_install() {
	dobin bin/tmsu
	use debug && dostrip -x /usr/bin/tmsu

	dosbin misc/bin/mount.tmsu
	dobin misc/bin/tmsu-*

	doman misc/man/tmsu.1

	insinto /usr/share/zsh/site-functions
	doins misc/zsh/_tmsu
}
