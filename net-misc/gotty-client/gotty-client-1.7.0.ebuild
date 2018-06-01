# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_VENDOR=(
	"github.com/jtolds/gls 77f1821"
	"github.com/smartystreets/assertions 7678a54"
	"github.com/smartystreets/goconvey 9e8dc3f"
)

inherit bash-completion-r1 golang-vcs-snapshot

EGO_PN="github.com/moul/${PN}"
DESCRIPTION="A terminal client for GoTTY"
HOMEPAGE="https://github.com/moul/gotty-client"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="bash-completion zsh-completion"

RDEPEND="zsh-completion? ( app-shells/zsh )"
RESTRICT="mirror strip"

DOCS=( README.md )

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"

	go build -v -ldflags "-s -w" \
		./cmd/gotty-client || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin gotty-client
	einstalldocs

	if use bash-completion; then
		newbashcomp contrib/completion/bash_autocomplete ${PN}
	fi

	if use zsh-completion; then
		insinto /usr/share/zsh/site-functions
		newins contrib/completion/zsh_autocomplete _${PN}
	fi
}
