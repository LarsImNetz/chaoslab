# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GIT_COMMIT="a251832" # Change this when you update the ebuild
EGO_PN="github.com/NebulousLabs/Sia"
# Snapshot taken on 2018.09.18
# Deps that are not needed:
# github.com/NebulousLabs/bolt a22e934
# github.com/inconshreveable/mousetrap 76626ae
EGO_VENDOR=(
	"github.com/NebulousLabs/demotemutex 235395f"
	"github.com/NebulousLabs/fastrand 3cf7173"
	"github.com/NebulousLabs/merkletree 1db44fa"

	"github.com/NebulousLabs/entropy-mnemonics 7b01a64"
	"github.com/NebulousLabs/errors 7ead97e"
	"github.com/NebulousLabs/go-upnp 29b680b"
	"github.com/NebulousLabs/ratelimit 9dddc2c"
	"github.com/NebulousLabs/threadgroup d137120"
	"github.com/NebulousLabs/writeaheadlog af695ed"
	"github.com/klauspost/reedsolomon 925cb01"
	"github.com/julienschmidt/httprouter 348b672"
	"github.com/inconshreveable/go-update 8152e7e"
	"github.com/kardianos/osext ae77be6"

	"github.com/spf13/cobra 8d114be"
	"github.com/spf13/pflag 298182f"
	"github.com/cpuguy83/go-md2man 691ee98"
	"github.com/klauspost/cpuid e7e905e"

	"golang.org/x/crypto 0e37d00 github.com/golang/crypto"
	"golang.org/x/net 26e67e7 github.com/golang/net"
	"golang.org/x/text 905a571 github.com/golang/text"
	"golang.org/x/sys d0be072 github.com/golang/sys"
	"gopkg.in/yaml.v2 5420a8b github.com/go-yaml/yaml"
)

inherit golang-vcs-snapshot systemd user

DESCRIPTION="Blockchain-based marketplace for file storage"
HOMEPAGE="https://sia.tech"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="pie"

QA_PRESTRIPPED="
	usr/bin/siac
	usr/bin/siad
"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup sia
	enewuser sia -1 -1 -1 sia
}

src_compile() {
	export GOPATH="${G}"
	export GOBIN="${S}"
	local myldflags=( -s -w
		-X "${EGO_PN}/build.GitRevision=${GIT_COMMIT}"
		-X "'${EGO_PN}/build.BuildTime=$(date -u)'"
	)
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "${myldflags[*]}"
	)
	go install "${mygoargs[@]}" ./cmd/sia{c,d} || die
}

src_install() {
	dobin siac siad
	dodoc doc/*.md

	newinitd "${FILESDIR}"/sia.initd sia
	systemd_dounit "${FILESDIR}"/sia.service

	diropts -o sia -g sia -m 0750
	keepdir /var/lib/sia
}
