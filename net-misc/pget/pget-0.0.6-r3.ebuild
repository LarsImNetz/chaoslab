# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# Note: Keep EGO_VENDOR in sync with glide.lock
EGO_VENDOR=(
	"github.com/antonholmquist/jason 962e09b"
	"github.com/asaskevich/govalidator 7b3beb6"
	"github.com/Code-Hex/updater c3f2786"
	"github.com/jessevdk/go-flags 4cc2832"
	"github.com/mcuadros/go-version d52711f"
	"github.com/mitchellh/go-homedir 756f7b1"
	"github.com/pkg/errors 839d9e9"
	"github.com/ricochet2200/go-disk-usage f0d1b74"
	"golang.org/x/net 8b4af36 github.com/golang/net"
	"golang.org/x/sync 1ae7c7b github.com/golang/sync"
	"gopkg.in/cheggaaa/pb.v1 9453b2d github.com/cheggaaa/pb"
	"github.com/davecgh/go-spew 6d21280"
	"github.com/dsnet/compress b9aab3c"
	"github.com/mholt/archiver 4a8a092"
	"github.com/nwaples/rardecode f948413"
	"github.com/pmezard/go-difflib d8ed262"
	"github.com/stretchr/testify 976c720"
)

inherit golang-vcs-snapshot

EGO_PN="github.com/Code-Hex/pget"
DESCRIPTION="A parallel file download client in Go"
HOMEPAGE="https://github.com/Code-Hex/pget"
SRC_URI="https://${EGO_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RESTRICT="mirror strip"

DOCS=( README.md )

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_compile() {
	export GOPATH="${G}"
	go build -v -ldflags "-s -w" \
		./cmd/pget || die
}

src_test() {
	go test -v ./... || die
}

src_install() {
	dobin pget
	einstalldocs
}
