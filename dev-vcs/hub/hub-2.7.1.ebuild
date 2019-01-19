# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/github/${PN}"

inherit bash-completion-r1 golang-vcs-snapshot-r1

DESCRIPTION="A command-line wrapper for git that makes you better at GitHub"
HOMEPAGE="https://hub.github.com/"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86" # Untested: arm arm64 x86
IUSE="bash-completion debug fish-completion man pie static zsh-completion"

DEPEND="man? ( app-text/ronn dev-ruby/bundler )"
RDEPEND="
	>=dev-vcs/git-1.7.3
	fish-completion? ( app-shells/fish )
	zsh-completion? ( app-shells/zsh )
"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_pretend() {
	if use man && [[ "${MERGE_TYPE}" != binary ]]; then
		# shellcheck disable=SC2086
		if has network-sandbox ${FEATURES}; then
			ewarn
			ewarn "${CATEGORY}/${PN}[man] requires 'network-sandbox' to be disabled in FEATURES"
			ewarn
			die "[network-sandbox] is enabled in FEATURES"
		fi
	fi
}

src_compile() {
	export GOPATH="${G}"
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"
	(use pie && use static) && CGO_LDFLAGS+=" -static"

	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "${EGO_PN}/version.Version=${PV}"
	)

	local mygoargs=(
		-v -work -x
		-buildmode "$(usex pie pie exe)"
		-asmflags "all=-trimpath=${S}"
		-gcflags "all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
		-tags "$(usex static 'netgo' '')"
		-installsuffix "$(usex static 'netgo' '')"
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
	use debug && dostrip -x /usr/bin/hub
	einstalldocs

	use man && doman share/man/man1/*.1
	use bash-completion && newbashcomp etc/hub.bash_completion.sh hub

	if use fish-completion; then
		insinto /usr/share/fish/completions
		newins etc/hub.fish_completion hub.fish
	fi

	if use zsh-completion; then
		insinto /usr/share/zsh/site-functions
		newins etc/hub.zsh_completion _hub
	fi
}
