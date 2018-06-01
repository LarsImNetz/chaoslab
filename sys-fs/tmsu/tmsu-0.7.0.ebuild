# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_VENDOR=(
	"github.com/hanwen/go-fuse 363c44c"
	"github.com/mattn/go-sqlite3 615c193"
	"golang.org/x/net a337091 github.com/golang/net"
	"golang.org/x/sys 75813c6 github.com/golang/sys"
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
IUSE="pie zsh-completion"

RDEPEND="zsh-completion? ( app-shells/zsh )"

QA_PRESTRIPPED="usr/bin/tmsu"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_prepare() {
	# Move the sources from src/${EGO_PN} to
	# ${S}, as we will use a vendored setup.
	mv src/${EGO_PN}/* ./ || die

	# We will only use make for tests,
	# so let's silence the "compile".
	sed -i "s/ compile//g" \
		Makefile || die

	default
}

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		$(usex pie '-buildmode=pie' '')
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
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

	if use zsh-completion; then
		insinto /usr/share/zsh/site-functions
		doins misc/zsh/_tmsu
	fi
}
