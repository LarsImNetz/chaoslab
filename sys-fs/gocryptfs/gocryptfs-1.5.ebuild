# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# Note: Keep FUSE_COMMIT in sync with Gopkg.lock
FUSE_COMMIT="291273c"
EGO_PN="github.com/rfjakob/${PN}"

inherit golang-vcs-snapshot

DESCRIPTION="Encrypted overlay filesystem written in Go"
HOMEPAGE="https://nuetzlich.net/gocryptfs"
SRC_URI="https://${EGO_PN}/releases/download/v${PV}/${PN}_v${PV}_src-deps.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="libressl pie +ssl"

RDEPEND="sys-fs/fuse:0
	ssl? (
		!libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:0= )
	)"

QA_PRESTRIPPED="usr/bin/gocryptfs"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local myldflags=( -s -w
		-X "main.GitVersion=${PV}"
		-X "main.GitVersionFuse=${FUSE_COMMIT}"
		-X "main.BuildDate=$(date '+%Y-%m-%d')"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "${myldflags[*]}"
		-tags "$(usex !ssl 'without_openssl' '')"
	)
	go build "${mygoargs[@]}" || die
}

src_install() {
	dobin gocryptfs
	newman "${FILESDIR}/${P}" gocryptfs.1
}
