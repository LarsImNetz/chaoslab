# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

#TODO: We an init script!

EGO_PN="github.com/shadowsocks/go-${PN}"
EGO_VENDOR=(
	"github.com/Yawning/chacha20 e3b1f96"
	"golang.org/x/crypto 2b6c088 github.com/golang/crypto"
)

inherit golang-vcs-snapshot user

DESCRIPTION="A fresh implementation of Shadowsocks in Go"
HOMEPAGE="https://github.com/shadowsocks/go-shadowsocks2"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="pie"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/shadowsocks2"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

#pkg_setup() {
#	enewgroup shadowsocks2
#	enewuser shadowsocks2 -1 -1 -1 shadowsocks2
#}

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w"
		-o shadowsocks2
	)
	go build "${mygoargs[@]}" || die
}

src_install() {
	dobin shadowsocks2
	einstalldocs
}
