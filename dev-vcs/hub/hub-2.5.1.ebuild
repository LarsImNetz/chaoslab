# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/github/${PN}"

inherit bash-completion-r1 golang-vcs-snapshot

DESCRIPTION="A command-line wrapper for git that makes you better at GitHub"
HOMEPAGE="https://hub.github.com/"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror test"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="bash-completion fish-completion man zsh-completion"

DEPEND="man? ( app-text/ronn dev-ruby/bundler )"
RDEPEND=">=dev-vcs/git-1.7.3
	fish-completion? ( app-shells/fish )
	zsh-completion? ( app-shells/zsh )"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/hub"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_setup() {
	if use man; then
		# shellcheck disable=SC2086
		if has network-sandbox $FEATURES; then
			ewarn ""
			ewarn "${CATEGORY}/${PN}[man] requires 'network-sandbox' to be disabled in FEATURES"
			ewarn ""
			die "[network-sandbox] is enabled in FEATURES"
		fi
	fi
}

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w -X ${EGO_PN}/version.Version=${PV}"
	)
	go build "${mygoargs[@]}" || die

	use man && emake man-pages
}

src_install() {
	dobin hub
	einstalldocs

	use bash-completion && \
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
