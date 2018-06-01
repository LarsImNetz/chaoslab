# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/scaleway/${PN}"
GIT_COMMIT="2ba2733" # Change this when you update the ebuild

inherit bash-completion-r1 golang-vcs-snapshot

DESCRIPTION="Interact with Scaleway API from the command line"
HOMEPAGE="https://www.scaleway.com"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="zsh-completion"

RDEPEND="zsh-completion? ( app-shells/zsh )"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/scw"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w -X ${EGO_PN}/pkg/scwversion.GITCOMMIT=${GIT_COMMIT}"
	)
	go build "${mygoargs[@]}" ./cmd/scw || die
}

src_test() {
	go test -v ./cmd/scw/ || die
	go test -v ./pkg/{sshcommand,pricing,cli}/ || die
}

src_install() {
	dobin scw
	einstalldocs

	newbashcomp contrib/completion/bash/scw.bash scw

	if use zsh-completion; then
		insinto /usr/share/zsh/site-functions
		doins contrib/completion/zsh/_scw
	fi
}
