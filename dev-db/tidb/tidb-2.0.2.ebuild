# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/pingcap/tidb"
GIT_COMMIT="78b49e8" # Change this when you update the ebuild

inherit golang-vcs-snapshot

DESCRIPTION="A distributed NewSQL database compatible with MySQL protocol"
HOMEPAGE="https://pingcap.com/"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="pie"

DOCS=( {CHANGELOG,README,docs/{QUICKSTART,ROADMAP}}.md )
QA_PRESTRIPPED="usr/bin/tidb-server"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_prepare() {
	# The tarball isn't a proper git repository,
	# so let's silence the "fatal" message.
	sed -i -e '/LDFLAGS +/d' Makefile || die

	default
}

src_compile() {
	export GOPATH="${G}"
	# shellcheck disable=SC2207
	local mygoargs=(
		-v -work -x
		$(usex pie '-buildmode=pie' '')
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w
			-X ${EGO_PN}/mysql.TiDBReleaseVersion=${PV}
			-X '${EGO_PN}/util/printer.TiDBBuildTS=$(date -u '+%Y-%m-%d %I:%M:%S')'
			-X ${EGO_PN}/util/printer.TiDBGitHash=${GIT_COMMIT}
			-X ${EGO_PN}/util/printer.TiDBGitBranch=non-git
			-X '${EGO_PN}/util/printer.GoVersion=$(go version)'"
		-o ./bin/tidb-server
	)
	emake parser
	go build "${mygoargs[@]}" ./tidb-server || die
}

src_test() {
	go test -v -p 3 -cover ./... || die
}

src_install() {
	dobin bin/tidb-server
	einstalldocs
}

pkg_postinst() {
	einfo
	elog "See https://pingcap.com/docs for configuration guide."
	einfo
}
