# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/github/hub"

inherit bash-completion-r1 golang-vcs-snapshot

DESCRIPTION="A command-line wrapper for git that makes you better at GitHub"
HOMEPAGE="https://hub.github.com/"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror test"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="fish-completion man zsh-completion"

DEPEND="man? ( app-text/ronn dev-ruby/bundler )"
RDEPEND=">=dev-vcs/git-1.7.3
	fish-completion? ( app-shells/fish )
	zsh-completion? ( app-shells/zsh )"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/hub"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_setup() {
	# shellcheck disable=SC2086
	if use man; then
		has network-sandbox $FEATURES && \
			die "dev-vcs/hub[man] require 'network-sandbox' to be disabled in FEATURES"
	fi
}

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w"
	)
	go build "${mygoargs[@]}" || die

	use man && emake -C man-pages
}

src_install() {
	dobin hub
	einstalldocs

	newbashcomp etc/hub.bash_completion.sh hub

	use man && doman share/man/man1/*.1

	if use fish-completion; then
		insinto /usr/share/fish/completions
		newins etc/hub.fish_completion hub.fish
	fi

	if use zsh-completion; then
		insinto /usr/share/zsh/site-functions
		newins etc/hub.zsh_completion _hub
	fi
}
