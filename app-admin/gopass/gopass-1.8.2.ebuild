# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/gopasspw/${PN}"
GIT_COMMIT="909c8ac" # Change this when you update the ebuild

inherit bash-completion-r1 golang-vcs-snapshot

DESCRIPTION="The slightly more awesome standard unix password manager for teams"
HOMEPAGE="https://www.gopass.pw"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="bash-completion fish-completion +pie zsh-completion"

RDEPEND="
	app-crypt/gpgme:1
	dev-vcs/git[threads,gpg,curl]
	fish-completion? ( app-shells/fish )
	zsh-completion? ( app-shells/zsh )
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
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)
	go build "${mygoargs[@]}" || die
}

src_install() {
	dobin gopass
	einstalldocs

	if use bash-completion; then
		./gopass completion bash > gopass.bash || die
		newbashcomp gopass.bash gopass
	fi

	if use fish-completion; then
		./gopass completion fish > gopass.fish || die
		insinto /usr/share/fish/functions
		doins gopass.fish
	fi

	if use zsh-completion; then
		./gopass completion zsh > _gopass || die
		insinto /usr/share/zsh/site-functions
		doins _gopass
	fi
}
