# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit golang-vcs-snapshot systemd user

GIT_COMMIT="7853e53"
EGO_PN="github.com/ipfs/${PN}"
DESCRIPTION="IPFS implementation written in Go"
HOMEPAGE="https://ipfs.io"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="fuse test"

RDEPEND="fuse? ( sys-fs/fuse:0 )"
DEPEND="|| ( net-misc/curl net-misc/wget )
	test? ( net-analyzer/netcat[crypt] )"

DOCS=( {CHANGELOG,README}.md )

QA_PRESTRIPPED="usr/bin/ipfs"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	has network-sandbox $FEATURES && \
		die "net-p2p/go-ipfs requires 'network-sandbox' to be disabled in FEATURES"
}

src_prepare() {
	sed -i \
		-e "s:-X:-s -w -X:" \
		-e "s:CurrentCommit=.*:CurrentCommit=${GIT_COMMIT}\":" \
		cmd/ipfs/Rules.mk || die

	default
}

src_compile() {
	export GOPATH="${G}"
	GOTAGS="$(usex !fuse nofuse '')" \
	emake build
}

src_test() {
	TEST_NO_FUSE=1 \
		emake test_go_short
}

src_install() {
	dobin cmd/ipfs/ipfs
	einstalldocs
}
