# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# Note: Keep EGO_VENDOR in sync with Gopkg.lock
FUSE_COMMIT="a9ddcb8"
EGO_VENDOR=(
	"github.com/hanwen/go-fuse ${FUSE_COMMIT}"
	"github.com/jacobsa/crypto c73681c"
	"github.com/rfjakob/eme 2222dbd"
	"golang.org/x/crypto 374053e github.com/golang/crypto"
	"golang.org/x/sync 1d60e46 github.com/golang/sync"
	"golang.org/x/sys 01acb38 github.com/golang/sys"
)

inherit golang-vcs-snapshot

EGO_PN="github.com/rfjakob/${PN}"
DESCRIPTION="Encrypted overlay filesystem written in Go"
HOMEPAGE="https://nuetzlich.net/gocryptfs"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="libressl +ssl"

RDEPEND="sys-fs/fuse:0
	ssl? (
		!libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:0= )
	)"
RESTRICT="mirror strip"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	local usessl
	local GOLDFLAGS="-s -w \
		-X main.GitVersion=${PV} \
		-X main.GitVersionFuse=${FUSE_COMMIT} \
		-X main.BuildTime=$(date +%s)"

	use ssl || usessl="-tags without_openssl"

	go build -v -ldflags \
		"${GOLDFLAGS}" ${usessl} || die
}

src_install() {
	dobin gocryptfs
	newman "${FILESDIR}"/${P}.1 gocryptfs.1
}
