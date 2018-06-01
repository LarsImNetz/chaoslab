# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_VENDOR=(
	"github.com/Yawning/chacha20 e3b1f96"
	"golang.org/x/crypto 2b6c088 github.com/golang/crypto"
)

inherit golang-vcs-snapshot user

EGO_PN="github.com/shadowsocks/go-${PN}"
DESCRIPTION="A fresh implementation of Shadowsocks in Go"
HOMEPAGE="https://github.com/shadowsocks/go-shadowsocks2"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror strip"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DOCS=( README.md )

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

#pkg_setup() {
#	enewgroup shadowsocks
#	enewuser shadowsocks -1 -1 -1 shadowsocks
#}

src_compile() {
	export GOPATH="${G}"
	go build -v -ldflags "-s -w" \
		-o ${PN} || die
}

src_install() {
	dobin ${PN}
	einstalldocs

	#TODO: Add an init script!
}
