# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/gopasspw/${PN}"
GIT_COMMIT="909c8ac88b" # Change this when you update the ebuild
# Snapshot taken on 2018.11.14
EGO_VENDOR=(
	"golang.org/x/crypto 3d3f9f4138 github.com/golang/crypto"
	"golang.org/x/sys 66b7b1311a github.com/golang/sys"
)

inherit bash-completion-r1 golang-vcs-snapshot

DESCRIPTION="The slightly more awesome standard unix password manager for teams"
HOMEPAGE="https://www.gopass.pw"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+pie"

RDEPEND="
	app-crypt/gpgme:1
	dev-vcs/git[threads,gpg,curl]
"

DOCS=( CHANGELOG.md README.md )
QA_PRESTRIPPED="usr/bin/gopass"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local myldflags=( -s -w
		-X "main.version=${PV}"
		-X "main.commit=${GIT_COMMIT}"
		-X "main.date=$(date -u '+%FT%T%z')"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)
	go build "${mygoargs[@]}" || die
}

src_install() {
	dobin gopass
	einstalldocs

	./gopass completion bash > gopass.bash || die
	newbashcomp gopass.bash gopass

	dodir /usr/share/fish/functions
	./gopass completion fish > "${ED%/}"/usr/share/fish/functions/gopass.fish || die

	dodir /usr/share/zsh/site-functions
	./gopass completion zsh > "${ED%/}"/usr/share/zsh/site-functions/_gopass || die
}
