# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_VENDOR=(
	"github.com/NebulousLabs/demotemutex 235395f"
	"github.com/NebulousLabs/fastrand 3cf7173"
	"github.com/NebulousLabs/merkletree 1db44fa"
	"github.com/NebulousLabs/bolt a22e934"
	"github.com/NebulousLabs/entropy-mnemonics 7b01a64"
	"github.com/NebulousLabs/errors 7ead97e"
	"github.com/NebulousLabs/go-upnp 29b680b"
	"github.com/NebulousLabs/ratelimit 01a32df"
	"github.com/NebulousLabs/threadgroup d137120"
	"github.com/NebulousLabs/writeaheadlog af695ed"

	"github.com/klauspost/reedsolomon 0b30fa7"
	"github.com/julienschmidt/httprouter adbc77e"
	"github.com/inconshreveable/go-update 8152e7e"
	"github.com/kardianos/osext ae77be6"
	"github.com/inconshreveable/mousetrap 76626ae"

	"github.com/spf13/cobra 7ee208b"
	"github.com/spf13/pflag 583c0c0"
	"github.com/cpuguy83/go-md2man 48d8747"
	"github.com/klauspost/cpuid e7e905e"

	"golang.org/x/crypto d644981 github.com/golang/crypto"
	"golang.org/x/net 5f9ae10 github.com/golang/net"
	"golang.org/x/text 7922cc4 github.com/golang/text"
	"golang.org/x/sys 79b0c68 github.com/golang/sys"
	"gopkg.in/yaml.v2 5420a8b github.com/go-yaml/yaml"
)

inherit golang-vcs-snapshot systemd user

GIT_COMMIT="72938f5"
EGO_PN="github.com/NebulousLabs/Sia"
DESCRIPTION="Blockchain-based marketplace for file storage"
HOMEPAGE="https://sia.tech"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror strip"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup sia
	enewuser sia -1 -1 -1 sia
}

src_compile() {
	export GOPATH="${G}"
	local GOLDFLAGS="-s -w
		-X ${EGO_PN}/Sia/build.GitRevision=${GIT_COMMIT}
		-X '${EGO_PN}/build.BuildTime=$(date)'"

	go install -v -ldflags "${GOLDFLAGS}" \
		./cmd/sia{c,d} || die
}

src_install() {
	dobin "${G}"/bin/sia{c,d}
	dodoc doc/*.md

	newinitd "${FILESDIR}"/sia.initd-r2 sia
	systemd_dounit "${FILESDIR}"/sia.service

	diropts -o sia -g sia -m 0750
	keepdir /var/lib/sia
}
