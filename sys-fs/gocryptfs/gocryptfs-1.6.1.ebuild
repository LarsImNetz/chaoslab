# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/rfjakob/${PN}"

inherit golang-vcs-snapshot-r1

DESCRIPTION="Encrypted overlay filesystem written in Go"
HOMEPAGE="https://nuetzlich.net/gocryptfs"
SRC_URI="https://${EGO_PN}/releases/download/v${PV}/${PN}_v${PV}_src-deps.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86" # Untested: arm arm64 x86
IUSE="debug libressl +man pie +ssl"

DEPEND="man? ( dev-util/go-md2man )"
RDEPEND="
	sys-fs/fuse:0
	ssl? (
		!libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:0= )
	)
"

QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"
	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "main.GitVersion=v${PV}"
		-X "'main.GitVersionFuse=[vendored]'"
		-X "main.BuildDate=$(date -u '+%Y-%m-%d')"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie exe)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
		-tags "$(usex !ssl 'without_openssl' 'none')"
	)
	go build "${mygoargs[@]}" || die
	use man && go-md2man -in Documentation/MANPAGE.md -out gocryptfs.1
}

src_install() {
	dobin gocryptfs
	use debug && dostrip -x /usr/bin/gocryptfs
	use man && doman gocryptfs.1
}
