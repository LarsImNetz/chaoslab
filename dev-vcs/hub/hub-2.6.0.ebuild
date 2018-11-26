# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/github/${PN}"

inherit bash-completion-r1 golang-vcs-snapshot

DESCRIPTION="A command-line wrapper for git that makes you better at GitHub"
HOMEPAGE="https://hub.github.com/"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="man pie"

DEPEND="man? ( app-text/ronn dev-ruby/bundler )"
RDEPEND=">=dev-vcs/git-1.7.3"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/hub"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_pretend() {
	if use man && [[ "${MERGE_TYPE}" != binary ]]; then
		# shellcheck disable=SC2086
		if has network-sandbox $FEATURES; then
			ewarn
			ewarn "${CATEGORY}/${PN}[man] requires 'network-sandbox' to be disabled in FEATURES"
			ewarn
			die "[network-sandbox] is enabled in FEATURES"
		fi
	fi
}

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "-s -w -X ${EGO_PN}/version.Version=${PV}"
	)
	go build "${mygoargs[@]}" || die

	use man && emake man-pages
}

src_test() {
	# Remove tests that doesn't play nicely with portage's sandbox
	rm commands/remote_test.go || die

	go test -v ./... || die
}

src_install() {
	dobin hub
	einstalldocs

	use man && doman share/man/man1/*.1

	newbashcomp etc/hub.bash_completion.sh hub

	insinto /usr/share/fish/completions
	newins etc/hub.fish_completion hub.fish

	insinto /usr/share/zsh/site-functions
	newins etc/hub.zsh_completion _hub
}
