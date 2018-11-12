# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GIT_COMMIT="ea363c1e0d198f9e8314051d0c25c66c57606f0e"
EGO_PN="github.com/tj/${PN}"
# Snapshot taken on 2018.11.12
EGO_VENDOR=(
	"github.com/apex/log d6c5facec1"
	"github.com/dustin/go-humanize 9f541cc9db"
	"github.com/fatih/color 3f9d52f717"
	"github.com/mattn/go-colorable efa589957c"
	"github.com/mattn/go-isatty 3fb116b820"
	"github.com/pkg/errors 059132a15d"
)

inherit golang-vcs-snapshot

DESCRIPTION="Remove unnecessary files from node_modules (.md, .ts, ...)"
HOMEPAGE="https://github.com/tj/node-prune"
SRC_URI="https://${EGO_PN}/archive/${GIT_COMMIT}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="pie"

DOCS=( Readme.md )
QA_PRESTRIPPED="usr/bin/node-prune"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "-s -w"
	)
	go build "${mygoargs[@]}" ./cmd/node-prune || die
}

src_install() {
	dobin node-prune
	einstalldocs
}
